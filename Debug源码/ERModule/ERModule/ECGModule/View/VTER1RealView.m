//
//  VTER1RealView.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import "VTER1RealView.h"
#import "VTCustomText.h"
#import "VTMBLEParser.h"

#define InvalidValue 0x7FFF
#define SampleRate 125
#define DefaultRecordTime 30

@interface VTER1RealView ()
@property (weak, nonatomic) IBOutlet UILabel *hrValLab;
@property (weak, nonatomic) IBOutlet UILabel *rateLab;
@property (weak, nonatomic) IBOutlet UILabel *hrUnitLab;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@property (weak, nonatomic) IBOutlet UIView *waveVieww;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *realView;

@property (nonatomic, strong) NSMutableArray *recordArray; // 记录波形缓存
@property (nonatomic, strong) NSMutableArray *recordCacheArray; //记录需要保存的数据

@property (nonatomic, strong) dispatch_source_t timer;  // 支持后台刷新
//@property (nonatomic, strong) NSTimer *timer; //

@property (nonatomic, strong) CAShapeLayer *subRefreshLayer;
// 录制阶段的线段渲染
@property (nonatomic, strong) CAShapeLayer *subRecordLayer;

@property (nonatomic, assign) BOOL isRecording;  //录制阶段
@property (nonatomic, assign) u_short repeatCount; // 计次器
@property (nonatomic, assign) u_short repeatCountLink; // 根据刷新频率 15次为1秒 刷新几次器

@property (nonatomic, strong) NSMutableArray *drawArray;
@property (nonatomic, strong) NSMutableArray *fliterPool;

@end

@implementation VTER1RealView
{
    float pt_per_mm;       // 每mm 对应的pt
    float mm_per_val;              //两个值的间隔对应的 mm数      计算得来
    float pt_per_val;           //两个点之间的距离对应的point点   决定点的x坐标
    int val_per_screen;           //    由屏宽除一个点对应的point点数   的来
    float mm_per_mV;            // 每mV 对应的mm数  对应Y值
    int refreshPoint;   // 单次刷新的点数
    CGFloat subH;
    int indexX;
}

static int waveArea = 4;
static float spacing = 2.0;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self  = [[[NSBundle mainBundle] loadNibNamed:@"ER1RealView" owner:self options:nil] firstObject];
        self.frame = frame;
        [self vt_initLet];
    }
    return self;
}

/// 初始化固定值
- (void)vt_initLet{
    mm_per_mV = 10;
    pt_per_mm = 1/(25.4/163);
    mm_per_val = 25.0/(SampleRate*1.0);   // 25 mm   125Hz  125 个点
    pt_per_val = pt_per_mm*mm_per_val;
    _fliterPool = [NSMutableArray array];
    _drawArray = [NSMutableArray array];
    _recordArray = [NSMutableArray array];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _recordBtn.layer.cornerRadius = 22;
    _recordBtn.layer.masksToBounds = YES;
    [_recordBtn setTitle:[VTCustomText sharedInstance].recordStr forState:UIControlStateNormal];
    _hrValLab.text = @"--";
}

- (void)clearCache{
    indexX = 0;
    _isRecording = NO;
    _hrValLab.text = @"--";
    [_fliterPool removeAllObjects];
    [_drawArray removeAllObjects];
    [_recordArray removeAllObjects];
    [self drawWave];
    [self closeTime];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_waveVieww setNeedsLayout];
    [_waveVieww layoutIfNeeded];
    [_realView setNeedsLayout];
    [_realView layoutSubviews];
    NSLog(@"%@", NSStringFromCGRect(_waveVieww.frame));
    subH = (CGRectGetHeight(_waveVieww.frame)-(waveArea+1)*spacing)/waveArea;
    if (subH*.5 < mm_per_mV*pt_per_mm + 2*pt_per_mm) { // 允许稍微出界 上下个延长一格
        mm_per_mV = 5;
    }else {
        mm_per_mV = 10;
    }
    _rateLab.text = [NSString stringWithFormat:@"25mm/s %dmm/mV", (int)mm_per_mV];
    CGFloat subW = CGRectGetWidth(_waveVieww.frame)-2*spacing;
    val_per_screen = (int)(subW/pt_per_val); // 计算每个屏幕显示点数  用于数据刷新
    for (UIView *v in _waveVieww.subviews) {
        if (![v isEqual:_realView]) {
            [v removeFromSuperview];
        }
    }
    for (int i = 0; i < waveArea; i ++) {
        UIView *subWaveView = [[UIView alloc] initWithFrame:CGRectMake(1, 1+ (1+subH)*i, subW, subH)];
        subWaveView.backgroundColor = [UIColor colorWithRed:118/255.0 green:118/255.0 blue:128/255.0 alpha:0.24];
        subWaveView.tag = 100 +i;
        [_waveVieww addSubview:subWaveView];
        subWaveView.layer.cornerRadius = 10;
        subWaveView.layer.masksToBounds = YES;
        
        CAShapeLayer *thinShapeLayer = [CAShapeLayer layer];
        thinShapeLayer.strokeColor = [[UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:0.24] CGColor];
        thinShapeLayer.fillColor = [[UIColor clearColor] CGColor];
        thinShapeLayer.lineWidth = 0.5;
        [subWaveView.layer addSublayer:thinShapeLayer];
        
        CAShapeLayer *thickShapeLayer = [CAShapeLayer layer];
        thickShapeLayer.strokeColor = [[UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:0.24] CGColor];
        thickShapeLayer.fillColor = [[UIColor clearColor] CGColor];
        thickShapeLayer.lineWidth = 0.5;
        [subWaveView.layer addSublayer:thickShapeLayer];
        
        CGMutablePathRef thinPath = CGPathCreateMutable();
        CGMutablePathRef thickPath = CGPathCreateMutable();
        
        for (int i = 1; i*pt_per_mm < subW; i ++) {  //每一毫米一个小格子
            if (i % 5 == 0) { //粗线条
                CGPathMoveToPoint(thickPath, nil, i*pt_per_mm, 0);
                CGPathAddLineToPoint(thickPath, nil, i*pt_per_mm, subH);
            }else{
                CGPathMoveToPoint(thinPath, nil, i*pt_per_mm, 0);
                CGPathAddLineToPoint(thinPath, nil, i*pt_per_mm, subH);
            }
        }
        //下半区域
        for (int i = 0; i*pt_per_mm < subH*.5; i ++) {
            if (i % 5 == 0) {
                CGPathMoveToPoint(thickPath, nil, 0, subH*.5 + i*pt_per_mm);
                CGPathAddLineToPoint(thickPath, nil, subW, subH*.5 + i*pt_per_mm);
            }else{
                CGPathMoveToPoint(thinPath, nil, 0, subH*.5 + i*pt_per_mm);
                CGPathAddLineToPoint(thinPath, nil, subW, subH*.5 + i*pt_per_mm);
            }
        }
        // 上半区域
        for (int i = 1; subH*.5 - i*pt_per_mm > 0; i ++) {
            if (i % 5 == 0) {
                CGPathMoveToPoint(thickPath, nil, 0, subH*.5 - i*pt_per_mm);
                CGPathAddLineToPoint(thickPath, nil, subW, subH*.5 - i*pt_per_mm);
            }else{
                CGPathMoveToPoint(thinPath, nil, 0, subH*.5 - i*pt_per_mm);
                CGPathAddLineToPoint(thinPath, nil, subW, subH*.5 - i*pt_per_mm);
            }
        }
        thickShapeLayer.path = thickPath;
        thinShapeLayer.path = thinPath;
        CGPathRelease(thickPath);
        CGPathRelease(thinPath);
    }
    [_waveVieww bringSubviewToFront:_realView];
}


- (IBAction)viewReport:(id)sender {
    if (_reportHandle) {
        _reportHandle();
    }
}

- (void)recordInBackgroundMode{
    NSLog(@"后台开始记录");
    [self recordData:_recordBtn];
}


// 开启录制
- (IBAction)recordData:(id)sender {
    if (_runStatus != 2) {
        if (_recordHandle) {
            _recordHandle(VTRecordStatusNotSupport, nil);
        }
        return;
    }
    _recordBtn.userInteractionEnabled = NO;
    _repeatCount = -1;
    _repeatCountLink = 0;
    [_recordBtn setTitle:@"30 秒" forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor colorWithRed:118/255.0 green:118/255.0 blue:128/255.0 alpha:0.24/1.0]];
    [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _recordCacheArray = [NSMutableArray array];
    _isRecording = YES;
    if (_recordHandle) {
        _recordHandle(VTRecordStatusStart, nil);
    }
}

- (void)countDown{
    if (!_isRecording) {
        return;
    }
    if (_repeatCount == DefaultRecordTime) {
        [_recordBtn setTitle:[VTCustomText sharedInstance].recordStr forState:UIControlStateNormal];
        [_recordBtn setUserInteractionEnabled:YES];
        [_recordBtn setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:245/255.0 alpha:1]];
        [_recordBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _isRecording = NO;
        if (_recordHandle) {
            _recordHandle(VTRecordStatusFinished, [_recordCacheArray copy]); // 录制完成
        }
        return;
    }
    [_recordBtn setTitle:[NSString stringWithFormat:@"%d 秒", DefaultRecordTime - _repeatCount] forState:UIControlStateNormal];
}

- (void)setHeartVal:(u_short)heartVal{
    _heartVal = heartVal;
    if (heartVal != 0) {
        _hrValLab.text = [NSString stringWithFormat:@"%d", heartVal];
    }else{
        _hrValLab.text = @"--";
    }
}

- (void)setReceiveArray:(NSArray *)receiveArray{
    _receiveArray = receiveArray;
    //取消滤波
    [_fliterPool addObjectsFromArray:receiveArray];
    [self createLayer];
    [self startTime];
}

- (void)setRunStatus:(u_char)runStatus{
    _runStatus = runStatus;
    if (runStatus == 0) {
//        [[VTMFilter shared] resetParams];
    }
}

//- (void)setIsBackgroundMode:(BOOL)isBackgroundMode{
//    _isBackgroundMode = isBackgroundMode;
//    if (!_isBackgroundMode) {
//        [self clearCache];
//    }
//}

#pragma mark - 开始定时器
- (void)startTime {
    if (!_timer) {
        dispatch_resume(self.timer);
    }
}
#pragma mark - 关闭定时器
- (void)closeTime {
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_source_set_cancel_handler(_timer, ^{
            self->_timer = nil;
        });
    }
}

#pragma mark - 懒加载
- (dispatch_source_t)timer {
    if (!_timer) {
        __weak typeof(self) weakSelf = self;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (1.0 / (60 / 4)) * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            [weakSelf refreshWave];
        });
    }
    return _timer;
}

//#pragma mark --- auto
//- (void)startTime{
//    if (!_timer) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 15) target:self selector:@selector(refreshWave) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:_timer
//                                     forMode:NSRunLoopCommonModes];
//    }
//}
//
//- (void)closeTime{
//    if (_timer) {
//        [_timer invalidate];
//        _timer = nil;
//    }
//}




- (void)recordEvent:(NSArray *)pointArr{
    if (_isRecording) {
        // 刷新Btn
        _repeatCountLink = _recordCacheArray.count / SampleRate;
        if (_repeatCountLink != _repeatCount) {
            _repeatCount ++;
            [self countDown];
        }
        [_recordCacheArray addObjectsFromArray:pointArr];
    }
}



- (void)refreshWave{
//    NSLog(@" 池内剩余点数1: %d", _fliterPool.count);
    NSMutableArray *tempArr = [NSMutableArray array];
    if (_fliterPool.count >= SampleRate) {
        refreshPoint = 18;
    }else if (_fliterPool.count >= SampleRate*0.5) {
        refreshPoint = 10;
    } else {
        refreshPoint = 6;
    }
    
    if (_fliterPool.count >= refreshPoint) {
        if (_runStatus == 2) {
            [tempArr addObjectsFromArray:[_fliterPool subarrayWithRange:NSMakeRange(0, refreshPoint)]];
        } else if (_runStatus == 1) {
            // 非测量状态绘制直线 同样的数据中的点也要移除
            for (int i = 0; i < refreshPoint; i++) {
                [tempArr addObject:@(0)];
            }
        }
        [_fliterPool removeObjectsInRange:NSMakeRange(0, refreshPoint)];
    }else {
        if (_runStatus != 2) {
            int count = _fliterPool.count;
            [tempArr addObjectsFromArray:_fliterPool];
            [_fliterPool removeAllObjects];
            for (int i = 0; i < refreshPoint - count; i ++) {
                [tempArr addObject:@(0)];
            }
        }
    }
//    NSLog(@" 池内剩余点数2: %d", _fliterPool.count);
    if (_runStatus == 1 || _runStatus == 2) {
        if (tempArr.count >= refreshPoint) {
            NSInteger diff = (_drawArray.count+tempArr.count) - val_per_screen*4;
            if (diff > 0) {
                int k = val_per_screen*4 - _drawArray.count;
                if (_isRecording) {
                    [_recordArray addObjectsFromArray:[tempArr subarrayWithRange:NSMakeRange(0, k)]];
                    
                    for (int i = 0; i < k; i ++) {
                        [_drawArray addObject:@(InvalidValue)];
                    }
                    for (int i = 0; i < diff; i ++) {
                        NSNumber *num = [tempArr objectAtIndex:i + k];
                        [_recordArray replaceObjectAtIndex:indexX withObject:num];
                        [_drawArray replaceObjectAtIndex:indexX withObject:@(InvalidValue)];
                        indexX ++;
                        if (indexX >= val_per_screen*4) {
                            indexX = 0;
                        }
                    }
                }else{
                    [_drawArray addObjectsFromArray:[tempArr subarrayWithRange:NSMakeRange(0, k)]];
                    for (int i = 0; i < k; i ++) {
                        [_recordArray addObject:@(InvalidValue)];
                    }
                    for (int i = 0; i < diff; i ++) {
                        NSNumber *num = [tempArr objectAtIndex:i + k];
                        [_drawArray replaceObjectAtIndex:indexX withObject:num];
                        [_recordArray replaceObjectAtIndex:indexX withObject:@(InvalidValue)];
                        indexX ++;
                        if (indexX >= val_per_screen*4) {
                            indexX = 0;
                        }
                    }
                }
            }else{
                indexX = 0;
                if (_isRecording) {
                    [_recordArray addObjectsFromArray:tempArr];
                    for (int i = 0; i < tempArr.count;  i++) { // 占位
                        [_drawArray addObject:@(InvalidValue)];
                    }
                }else{
                    [_drawArray addObjectsFromArray:tempArr];
                    for (int i = 0; i < tempArr.count;  i++) { // 占位
                        [_recordArray addObject:@(InvalidValue)];
                    }
                }
            }
        }
        [self recordEvent:tempArr];
        [self drawWave];
    }else {
        if (_drawArray.count > 0) {
            [self clearCache];
            if (_recordHandle) {
                _recordHandle(VTRecordStatusFailed, nil);
            }
        }else{
            [self drawWave];
        }
    }
}

- (void)drawWave{
//    NSLog(@"%s:<Line:%d>, 绘制图形的点数:%d", __func__, __LINE__, _drawArray.count);
    if (_isBackgroundMode) { // 后台模式不刷新UI  减少对GPU的使用
        return;
    }
    CGMutablePathRef path0 = CGPathCreateMutable();  // 原图
    CGMutablePathRef path1 = CGPathCreateMutable();  //渲染
    BOOL isVailed = YES; // 当前_drawArray.count == 4*val_per_screen &&  (i >= indexX && i < indexX + 10)
    BOOL isRecordFirst = YES;
    BOOL isDrawFirst = YES;
    BOOL fullScreen = (_drawArray.count == 4*val_per_screen);
    for (int i = 0; i < _drawArray.count; i ++) {
        int mod = i % val_per_screen;
        int div = i / val_per_screen;
        if ((fullScreen && (i >= indexX && i < indexX + 10))) {
            isVailed = NO;
            continue;
        }
        CGFloat offsetx = mod * pt_per_val;
        NSNumber *val = _drawArray[i];
        if ([val isEqualToNumber:@(InvalidValue)]) {
            val = _recordArray[i];
            CGFloat offsety = [self transferY:val.shortValue] + spacing*(div + 1) + subH*div;
            if (isRecordFirst) { //第一个渲染的点
                if (mod == 0) { //首个点绘制 无需连线
                    CGPathMoveToPoint(path1, nil, offsetx, offsety);
                }else {
                    // 需与前一个点连线
                    NSNumber *preVal = _drawArray[i-1];
                    if ([preVal isEqualToNumber:@(InvalidValue)]) {  // 前一个点无效时 作为起点
                        CGPathMoveToPoint(path0, nil, offsetx, offsety);
                    }else{
                        CGFloat preX = (i-1) %val_per_screen * pt_per_val;
                        CGFloat preY = [self transferY:preVal.shortValue] + spacing*(div + 1) + subH*div;
                        CGPathMoveToPoint(path1, nil, preX, preY);
                        CGPathAddLineToPoint(path1, nil, offsetx, offsety);
                    }
                }
                isRecordFirst = NO;
            }else if (mod == 0 || !isVailed) {
                if (!isVailed) isVailed = YES;
                CGPathMoveToPoint(path1, nil, offsetx, offsety);
            }else{
                CGPathAddLineToPoint(path1, nil, offsetx, offsety);
            }
            isDrawFirst = YES;
        }else{
            CGFloat offsety = [self transferY:val.shortValue] + spacing*(div + 1) + subH*div;
            if (isDrawFirst) {
                if (mod == 0) { //首个点绘制 无需连线
                    CGPathMoveToPoint(path0, nil, offsetx, offsety);
                }else {
                    // 需与前一个点连线
                    NSNumber *preVal = _recordArray[i-1];
                    if ([preVal isEqualToNumber:@(InvalidValue)]) {
                        CGPathMoveToPoint(path0, nil, offsetx, offsety);
                    }else{
                        CGFloat preX = (i-1) %val_per_screen * pt_per_val;
                        CGFloat preY = [self transferY:preVal.shortValue] + spacing*(div + 1) + subH*div;
                        CGPathMoveToPoint(path0, nil, preX, preY);
                        CGPathAddLineToPoint(path0, nil, offsetx, offsety);
                    }
                }
                isDrawFirst = NO;
            }else if (mod == 0 || !isVailed) {
                if (!isVailed) isVailed = YES;
                CGPathMoveToPoint(path0, nil, offsetx, offsety);
            }else{
                CGPathAddLineToPoint(path0, nil, offsetx, offsety);
            }
            isRecordFirst = YES;
        }
    }
    _subRefreshLayer.path = path0;
    _subRecordLayer.path = path1;
    CGPathRelease(path0);
    CGPathRelease(path1);
}

- (CGFloat)transferY:(short)val{
//    NSLog(@"当前值:%f", val);
    CGFloat y = subH*0.5 - [VTMBLEParser mVFromShort:val]*mm_per_mV*pt_per_mm;
    return y;
}

- (void)createLayer{
    if (_subRefreshLayer) {
        return;
    }
    _subRefreshLayer = [CAShapeLayer layer];
    _subRefreshLayer.strokeColor = [[UIColor colorWithRed:41/255.0 green:239/255.0 blue:87/255.0 alpha:1/1.0] CGColor];
    _subRefreshLayer.fillColor = [[UIColor clearColor] CGColor];
    _subRefreshLayer.lineWidth = 1.0;
    [_realView.layer addSublayer:_subRefreshLayer];
    
    _subRecordLayer = [CAShapeLayer layer];
    _subRecordLayer.strokeColor = [[UIColor colorWithRed:224/255.0 green:230/255.0 blue:42/255.0 alpha:1/1.0] CGColor];
    _subRecordLayer.fillColor = [[UIColor clearColor] CGColor];
    _subRecordLayer.lineWidth = 1.0;
    [_realView.layer addSublayer:_subRecordLayer];
}

@end

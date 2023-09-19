//
//  VTER1RealViewController.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import <Masonry/Masonry.h>
#import "VTER1RealViewController.h"
#import "VTER1HistoryViewController.h"
#import "VTER1RealView.h"
#import "UIBatteryView.h"
#import "VTCustomText.h"
#import "VTBLEUtils.h"
#import "VTER1Utils.h"
#import "ERRecordECG.h"
#import "MBProgressHUD.h"
#import "ERFileManager.h"
#import "ERSyncManager.h"
#import "VTScanDashboard.h"
#import "AppDelegate.h"
#import "VTMarco.h"
#import "ECGReportInfoData.h"
#import "ViaReportWave.h"
#import "ViaPDFManager.h"
#import "ERECGReport.h"
#import "UIColor+Extensions.h"
#import "UIView+Additional.h"

@interface VTER1RealViewController ()<VTBLEUtilsDelegate, VTMURATDeviceDelegate, VTMURATUtilsDelegate, UIGestureRecognizerDelegate, VTScanDashboardDelegate>

@property (nonatomic, strong) VTER1RealView *realView;

@property (nonatomic, strong) UIBatteryView *batteryView;

@property (nonatomic, strong) NSTimer *timer; //

@property (nonatomic, strong) NSMutableArray *deviceListArray;
@property (nonatomic, strong) NSMutableArray *deviceIDArray;
@property (nonatomic, strong) ERRecordECG *recordECG;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, assign) BOOL isBackgroundMode;

@property (nonatomic, assign) NSInteger timestamp; // 进入后台模式 记录时间戳  每隔1min 检测一次时间戳 当30min 时 重置时间戳为当前 并开始记录  循环往复

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) VTScanDashboard *scanDashboard;


@end

@implementation VTER1RealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor brownColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModule)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *rightItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    _batteryView = [[UIBatteryView alloc] initWithPosition:CGPointMake(0, 15) borderColor:RGBA(190, 195, 206, 1.0) lowBattery:0.3];
    [rightItemView addSubview:_batteryView];
    UIButton *deviceBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_batteryView.frame) + 10, 4, 44, 22)];
    [deviceBtn setTitle:[VTCustomText sharedInstance].deviceStr forState:UIControlStateNormal];
    [deviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deviceBtn addTarget:self action:@selector(scanDevice:) forControlEvents:UIControlEventTouchUpInside];
    [deviceBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightItemView addSubview:deviceBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
    
    _realView = [[VTER1RealView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_realView];
    [self realClickEvent];
    [VTER1Utils sharedInstance].delegate = self;
    [VTER1Utils sharedInstance].deviceDelegate = self;
    [VTBLEUtils sharedInstance].delegate = self;
    [[VTBLEUtils sharedInstance] createBleManager];
    
    _isBackgroundMode = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnterBackgroundMode:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnterForegroundMode:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}


#pragma mark --- 前后台检测
- (void)appEnterBackgroundMode:(NSNotification *)notification{
    _timestamp = [[NSDate date] timeIntervalSince1970];
    _isBackgroundMode = YES;
    _realView.isBackgroundMode = _isBackgroundMode;
}

- (void)appEnterForegroundMode:(NSNotification *)notification{
    _timestamp = 0;
    _isBackgroundMode = NO;
    _realView.isBackgroundMode = _isBackgroundMode;
}

#pragma mark --- auto
- (void)startTimer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestRealtimeData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer{
    if (_timer) {
        [_realView clearCache];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)requestRealtimeData{
    if (_isBackgroundMode) {
        NSInteger currentStamp = [[NSDate date] timeIntervalSince1970];
        if (currentStamp - _timestamp >= [VTCustomText sharedInstance].receiveInterval) {
            _timestamp = currentStamp;
            [_realView recordInBackgroundMode];
        }
    }
    [[VTER1Utils sharedInstance] requestECGRealData];
}

#pragma mark --- event 
- (void)realClickEvent{
    __weak typeof(self) weakSelf = self;
    _realView.reportHandle = ^{
        //        NSBundle *bundle = [NSBundle bundleForClass:[VTER1HistoryViewController class]];
        //        VTER1HistoryViewController *vc = [[VTER1HistoryViewController alloc] initWithNibName:@"ERModule.framework/VTER1HistoryViewController" bundle:bundle];
        //        [weakSelf.navigationController pushViewController:vc animated:YES];
        VTER1HistoryViewController *vc = [[VTER1HistoryViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    _realView.recordHandle = ^(VTRecordStatus status, NSArray * _Nullable recordArray) {
        if (status == VTRecordStatusNotSupport) {
            [weakSelf showWarningAndErrorString:@"导联脱落，无法记录"];
        }else if (status == VTRecordStatusFailed) {
            [weakSelf showWarningAndErrorString:@"导联脱落，记录失败"];
        }else if (status == VTRecordStatusStart) {
            weakSelf.recordECG = [[ERRecordECG alloc] init];
            weakSelf.recordECG.deviceName = [VTER1Utils sharedInstance].peripheral.name;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setLocale:[NSLocale systemLocale]];
            [dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
            NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
            weakSelf.recordECG.startTime = strDate;
            weakSelf.recordECG.fileUrl = [NSString stringWithFormat:@"VTER1FileFold/%@.txt", strDate];
            weakSelf.recordECG.manaul = !weakSelf.isBackgroundMode;
        }else{
            NSMutableString *originalTxt =  [NSMutableString stringWithString:@"F-0-01,125,II,405.35"];
            for (int i = 0; i < 3750; i++) {  // 30s  125Hz
                short ecg_num = [recordArray[i] shortValue];
                [originalTxt appendString:[NSString stringWithFormat:@",%d", ecg_num]];
            }
            NSData *txtData = [originalTxt dataUsingEncoding:NSUTF8StringEncoding];
            [ERFileManager saveFile:[weakSelf.recordECG.startTime stringByAppendingString:@".txt"] FileData:txtData withDirectoryName:@"VTER1FileFold"];
            [weakSelf.recordECG save];
            //            if (!weakSelf.recordECG.manaul) {
            [weakSelf autoAiAnalysis:weakSelf.recordECG];
            //            }else{
            //                [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordEcgSaved" object:nil userInfo:@{@"ecg": weakSelf.recordECG}];
            //            }
        }
    };
}

- (void)closeModule{
    [self stopTimer];
    [[VTBLEUtils sharedInstance] cancelConnect:[VTBLEUtils sharedInstance].deviceArray.firstObject];
    //    [VTER1Utils sharedInstance].peripheral = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanDevice:(UIButton *)btn{
    _maskView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    window.userInteractionEnabled = YES;
    UIViewController *presentedVC = [[window rootViewController] presentedViewController];
    if (presentedVC) {
        [presentedVC.view addSubview:_maskView];
    } else {
        [window.rootViewController.view addSubview:_maskView];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelScan)];
    tap.delegate = self;
    [_maskView addGestureRecognizer:tap];
    
    _scanDashboard = [[VTScanDashboard alloc] initWithFrame:CGRectMake(16, ISIPHONEX ? 88 : 64, kScreenWidth - 32, kScreenHeight - (ISIPHONEX ? 88 : 64) - (ISIPHONEX ? 39 : 0) - 100)];
    _scanDashboard.delegate = self;
    [_maskView addSubview:_scanDashboard];
    [self startScan];
    
}

- (void)startScan{
    if ([VTBLEUtils sharedInstance].deviceArray.count != 0) {
        [_scanDashboard addConnectedDevice:[VTBLEUtils sharedInstance].deviceArray.firstObject];
    }
    [[VTBLEUtils sharedInstance] startScanWithTime:NSUIntegerMax];
}

#pragma mark --- dashboard delegate

- (void)restartScan{
    [[VTBLEUtils sharedInstance] stopScan];
    [self startScan];
}

- (void)connectToDevice:(VTDevice *)device{
    if ([VTBLEUtils sharedInstance].deviceArray.count != 0) {
        [[VTBLEUtils sharedInstance] cancelConnect:[VTBLEUtils sharedInstance].deviceArray.firstObject];
    }
    [[VTBLEUtils sharedInstance] connectToDevices:@[device]];
}

- (void)disconnectDevice:(VTDevice *)device{
    [[VTBLEUtils sharedInstance] cancelConnect:device];
}

#pragma mark --- other

- (void)cancelScan{
    [[VTBLEUtils sharedInstance] stopScan];
    [_maskView removeFromSuperview];
    _maskView = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
    CGPoint point = [tap locationInView:_maskView];
    BOOL isIn = CGRectContainsPoint(_scanDashboard.frame,point);
    return !isIn;
}


- (void)autoAiAnalysis:(ERRecordECG *)recordECG{
    //    [ERSyncManager syncRecordEcg:recordECG.fileUrl finished:^(NSString * _Nullable msg, NSInteger code, NSDictionary * _Nullable response) {
    //        if (code == 200) {
    //            /**
    //             @property (nonatomic, copy) NSString *hr;
    //             @property (nonatomic, copy) NSString *isShowAiResult;
    //             @property (nonatomic, copy) NSString *shortRangeTime;
    //             @property (nonatomic, copy) NSString *sendTime;
    //             @property (nonatomic, copy) NSString *levelCode;
    //             @property (nonatomic, copy) NSString *aiResult;
    //             @property (nonatomic, copy) NSString *aiDiagnosis;
    //             */
    //            [recordECG setResponseData:response];
    //            [recordECG setHr:[response objectForKey:@"hr"]];
    //            [recordECG setIsShowAiResult:[response objectForKey:@"isShowAiResult"]];
    //            [recordECG setShortRangeTime:[response objectForKey:@"shortRangeTime"]];
    //            [recordECG setSendTime:[response objectForKey:@"sendTime"]];
    //            [recordECG setLevelCode:[response objectForKey:@"levelCode"]];
    //            [recordECG setAiResult:[response objectForKey:@"aiResult"]];
    //            [recordECG setAiDiagnosis:[response objectForKey:@"aiDiagnosis"]];
    //            [self productAIReportWithEcg:recordECG];
    //        }else {
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordEcgSaved" object:nil userInfo:@{@"ecg": recordECG}];
    //        }
    //    }];
    
    [[ERSyncManager sharedInstance] commitECGRecord:recordECG finished:^(NSString * _Nullable msg, NSInteger code, NSDictionary * _Nullable response) {
        if (code == 0) {
            recordECG.isShowAiResult = [response objectForKey:@"isShowAiResult"];
            recordECG.hr = [response objectForKey:@"hr"];
            recordECG.shortRangeTime = [response objectForKey:@"shortRangeTime"];
            recordECG.sendTime = [response objectForKey:@"sendTime"];
            recordECG.aiResult = [response objectForKey:@"aiResult"];
            recordECG.aiDiagnosis = [response objectForKey:@"aiDiagnosis"];
            [recordECG setResponseData:response];
            //            [recordECG update];
            [self productAIReportWithEcg:recordECG];
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordEcgSaved" object:nil userInfo:@{@"ecg": recordECG}];
        }
    }];
}

#pragma mark --- ble delegate
- (void)updateBleState:(VTBLEState)state{
    if (state == VTBLEStatePoweredOn) {
        [[VTBLEUtils sharedInstance] startScanWithTime:3];
        [self showWaitLoadingAnimationWithText:@"正在搜索..."];
        _deviceIDArray = [NSMutableArray array];
        _deviceListArray = [NSMutableArray array];
    }else {
        [self stopTimer];
    }
}

- (void)didDiscoverDevice:(VTDevice *)device{
    if (_maskView) {
        [_scanDashboard addScanningDevice:device];
    }else{
        NSUUID *identifier = [device.rawPeripheral identifier];
        if ([_deviceIDArray containsObject:identifier]) {
            NSUInteger index = [_deviceIDArray indexOfObject:identifier];
            [_deviceListArray replaceObjectAtIndex:index withObject:device];
        }else{
            [_deviceListArray addObject:device];
            [_deviceIDArray addObject:identifier];
        }
    }
}

- (void)scanCompletion{
    if (_deviceListArray.count == 0) {
        [self showWarningAndErrorString:@"未发现可用的设备"];
        return;
    }
    [_deviceListArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ABS(([[(VTDevice *)obj1 RSSI] intValue])) > ABS([[(VTDevice *)obj2 RSSI] intValue]);
    }];
    [self showWaitLoadingAnimationWithText:@"正在连接..."];
    [[VTBLEUtils sharedInstance] connectToDevices:@[_deviceListArray.firstObject]];
}

- (void)didConnectedDevice:(VTDevice *)device{
    NSLog(@"%s<line:%d>:(%@)连接成功",__func__,__LINE__,device.advName);
    [self hiddenWarningAndErrorAnimation];
    [self showWarningAndErrorString:@"连接成功，获取数据"];
    CBPeripheral *rawPeripheral = device.rawPeripheral;
    if (_maskView) {
        [_scanDashboard addConnectedDevice:device];
    }
    [VTER1Utils sharedInstance].peripheral = rawPeripheral;
}

- (void)didDisconnectedDevice:(VTDevice *)device andError:(NSError *)error{
    NSLog(@"%s<line:%d>:(%@)已断开连接",__func__,__LINE__,device.advName);
    [self stopTimer];
    if (error) {
        [[VTBLEUtils sharedInstance] connectToDevices:@[device]];
    }
}

#pragma mark --- vtm device delegate

- (void)utilDeployCompletion:(VTMURATUtils *)util{
    NSLog(@"%s<line:%d>:(%@)服务配置完成",__func__,__LINE__,util.peripheral.name);
    [self startTimer];
}

- (void)utilDeployFailed:(VTMURATUtils *)util{
    
}

- (void)util:(VTMURATUtils *)util updateDeviceRSSI:(NSNumber *)RSSI{
    
}

#pragma mark --- vtm communicate delegate
- (void)util:(VTMURATUtils *)util commandCompletion:(u_char)cmdType deviceType:(VTMDeviceType)deviceType response:(NSData *)response{
    if (deviceType == VTMDeviceTypeECG) {
        if (cmdType == VTMECGCmdGetRealData) {
            //            NSMutableArray *tempArray = [NSMutableArray array];
            NSMutableArray *originalArray = [NSMutableArray array];  //存储原始数据 用于AI分析
            VTMRealTimeData rd = [VTMBLEParser parseRealTimeData:response];
            VTMRealTimeWF wf = rd.waveform;
            for (int i = 0; i < wf.sampling_num; i ++) {
                short mv = wf.wave_data[i];
                if (wf.wave_data[i] != 0x7FFF) {// invalid Value
                    [originalArray addObject:@(mv)];
                    //                    [tempArray addObject:@([VTMBLEParser mVFromShort:mv])];
                }
            }
            VTMRunStatus splitRunStatus = [VTMBLEParser parseStatus:rd.run_para.run_status];
            VTMFlagDetail splitFlag = [VTMBLEParser parseFlag:rd.run_para.sys_flag];
            [_batteryView setCurBat:(rd.run_para.percent*1.0)/100 curState:[NSString stringWithFormat:@"%hhu", splitFlag.batteryStatus]];
            _realView.heartVal = rd.run_para.hr;
            _realView.runStatus = splitRunStatus.curStatus;
            _realView.receiveArray = originalArray;
        }
    }
}

- (void)util:(VTMURATUtils *)util commandFailed:(u_char)cmdType deviceType:(VTMDeviceType)deviceType failedType:(VTMBLEPkgType)type{
    
}

- (void)receiveHeartRateByStandardService:(Byte)hrByte{
    
}

#pragma mark --- 生成报告

- (NSString *)generateERAIReportFile:(ERRecordECG *)ecg{
    NSMutableArray *subViews = [NSMutableArray arrayWithCapacity:8];
    
    // 创建患者信息卡片
    ECGReportInfoData *userInfo = [[NSBundle mainBundle] loadNibNamed:@"ECGReportInfoData" owner:self options:nil].lastObject;
    userInfo.bounds = CGRectMake(0, 0, 0, 140);
    userInfo.member = [VTCustomText sharedInstance].user;
    userInfo.ecgRecord = ecg;
    [subViews addObject:userInfo];
    NSDictionary *dic = [ecg dataDicFromData];
    // 创建AI分析建议
    NSArray *aiResultList = [dic objectForKey:@"aiResultList"];
    
    
    for (int i=0; i < aiResultList.count; i++) {
        NSDictionary * tmpDic = aiResultList[i];
        NSString *sugStr ;
        NSString * tmp = tmpDic[@"phoneContent"];
        NSString * phoneText =[tmp stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        sugStr = [NSString stringWithFormat:@"%@\n%@",tmpDic[@"aiDiagnosis"],phoneText];
        
        UILabel *sugLab = [[UILabel alloc] init];
        sugLab.font = [UIFont systemFontOfSize:11];
        sugLab.text = sugStr;
        sugLab.textColor = [UIColor colorWithHex:000000];
        sugLab.numberOfLines = 0;
        sugLab.layer.borderWidth = 1;
        sugLab.layer.borderColor = [UIColor blackColor].CGColor;
        CGRect r = [sugStr boundingRectWithSize:CGSizeMake(wave_width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                        context:nil];
        sugLab.bounds = CGRectMake(0, 0, r.size.width, r.size.height + 14);
        [subViews addObject:sugLab];
    }
    
    // 创建心电波形片段
    NSArray *pointsArr = [ecg readShortFilePoints];
    if ([pointsArr.firstObject isEqual:@"F-0-01"]) {
        pointsArr = [pointsArr subarrayWithRange:NSMakeRange(1, pointsArr.count - 1)];
    }
    CGFloat scale = [pointsArr[2] doubleValue];
    NSArray *fragmentList;
    
    fragmentList = [dic objectForKey:@"fragmentList"];
    fragmentList = [fragmentList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"startPose"] integerValue] > [obj2[@"startPose"] integerValue];
    }];
    
    
    NSArray *posList = [dic objectForKey:@"posList"];
    NSArray *labelList = [dic objectForKey:@"labelList"];
    for (NSDictionary *fragment in fragmentList) {
        // 获取心电波形片段点数据
        // 获取心电波形片段点数据
        NSInteger startPose, endPose;
        
        
        startPose = [fragment[@"startPose"] integerValue] / 2;
        endPose = [fragment[@"endPose"] integerValue] / 2;
        
        
        NSArray *waveArray = [pointsArr subarrayWithRange:NSMakeRange(3, pointsArr.count - 3)];   // 点数据数组前3位为标记位, 取点数据时需剔除
        
        
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = (NSDate *)[formatter dateFromString:ecg.startTime];
        NSInteger mi = [date timeIntervalSince1970] + (startPose / 125);
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:mi]];
        
        ViaReportWave *ecgWave = [[ViaReportWave alloc] initWithFrame:CGRectMake(0, 0, 0, H_PER_ROW+viapadding)
                                                            waveArray:waveArray
                                                                range:NSMakeRange(startPose, endPose - startPose)
                                                                   hz:125
                                                                ruler:1.0
                                                                scale:scale];
        
        ecgWave.startTime = timeStr;
        
        NSInteger tagStartIndex = [posList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj integerValue] / 2 >= startPose) {
                *stop = YES;
            }
            return *stop;
        }];
        NSInteger tagEndIndex = [posList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj integerValue] / 2 > endPose) {
                *stop = YES;
            }
            return *stop;
        }];
        
        if (tagEndIndex > posList.count) {
            tagEndIndex = posList.count;
        }
        NSArray *tagLocations = [posList subarrayWithRange:NSMakeRange(tagStartIndex, tagEndIndex - tagStartIndex)];
        NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:10];       // 还原成125采样率后的下标数组
        [tagLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [arrM addObject:[NSString stringWithFormat:@"%ld", [obj integerValue] / 2]];
        }];
        
        NSArray *tagArray = [labelList subarrayWithRange:NSMakeRange(tagStartIndex, tagEndIndex - tagStartIndex)];
        ecgWave.ecgTagArr = tagArray;
        ecgWave.tagLocations = arrM;
        ecgWave.symptom = fragment[@"name"];
        
        [subViews addObject:ecgWave];
    }
    
    // 创建页底字符
    NSString *remindStr = @"*由于检测者基本健康情况、检测环境以及设备状态受多因素影响，本报告结果供参考，请您关注心脏健康，根据建议及时就医。 \r\n客服电话：400-622-1120。";
    UILabel *remindLabel = [[UILabel alloc] init];
    remindLabel.font = [UIFont systemFontOfSize:11];
    remindLabel.text = remindStr;
    remindLabel.textColor = [UIColor colorWithHex:000000];
    remindLabel.numberOfLines = 0;
    CGRect labr = [remindStr boundingRectWithSize:CGSizeMake(wave_width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                          context:nil];
    CGSize labelSize = labr.size;
    remindLabel.bounds = CGRectMake(0, 0, labelSize.width, labelSize.height + 14);
    [subViews addObject:remindLabel];
    
    NSArray *imageArr = [self generatePDFPage:subViews];
    
    NSString *filePath = [ecg.startTime stringByAppendingString:@".pdf"];
    [ViaPDFManager createPDFFileWithImage:imageArr toDestFile:filePath];
    return filePath;
}

- (NSArray <UIImage *> *)generatePDFPage:(NSMutableArray <UIView *> *)subViews {
    NSMutableArray <UIImage *> *imageArrM = [NSMutableArray arrayWithCapacity:4];
    do {
        ERECGReport *report = [[ERECGReport alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height)];
        CGFloat height = report.contentView.bounds.size.height;
        while (height > subViews.firstObject.bounds.size.height) {
            [report.contentView addSubview:subViews.firstObject];
            [subViews.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(report.contentView);
                make.top.equalTo(report.contentView).offset(report.contentView.bounds.size.height - height);
                make.height.mas_equalTo(subViews.firstObject.bounds.size.height);
            }];
            [subViews.firstObject layoutIfNeeded];
            
            height -= subViews.firstObject.bounds.size.height + 10;
            [subViews removeObject:subViews.firstObject];
        }
        [report layoutIfNeeded];
        [imageArrM addObject:[report captureView]];
    } while (subViews.count > 0);
    return imageArrM;
}

#pragma mark --- 生成报告 并保存URL

- (void)productAIReportWithEcg:(ERRecordECG *)ecg{
    dispatch_async(dispatch_get_main_queue(), ^{
        ecg.aiReportUrl = [self generateERAIReportFile:ecg];
        [ecg update];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordEcgSaved" object:nil userInfo:@{@"ecg": ecg}];
    });
}

#pragma mark --- MB progress hud

- (void)showWarningAndErrorString:(NSString*)text
{
    if([text isEqualToString:@""])
    {
        return;
    }
    [self hiddenWaitAnimation];
    MBProgressHUD* hud = (MBProgressHUD*)[self.view viewWithTag:913];
    
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] init];
        [hud setMode:MBProgressHUDModeText];
        hud.tag = 913;
        [self.view addSubview:hud];
    }
    [self.view bringSubviewToFront:hud];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    hud.bezelView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    hud.detailsLabel.text = text;
    hud.detailsLabel.textColor = [UIColor darkTextColor];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1.5f];
}

- (void)hiddenWarningAndErrorAnimation
{
    MBProgressHUD* hud = (MBProgressHUD*)[self.view viewWithTag:913];
    if(hud != nil)
    {
        [hud hideAnimated:YES];
        [hud removeFromSuperview];
    }
}


- (void)showWaitLoadingAnimationWithText:(NSString*)text
{
    MBProgressHUD* hud = (MBProgressHUD*)[self.view viewWithTag:888];
    if (hud == nil) {
        CGSize size = self.view.bounds.size;
        hud = [[MBProgressHUD alloc] initWithFrame:CGRectMake(size.width/2 - 70/2, size.height/2 - 70/2, 70, 70)];
        //        hud.dimBackground = NO;
        hud.tag = 888;
        [self.view addSubview:hud];
    }
    [self.view bringSubviewToFront:hud];
    hud.contentColor = [UIColor blackColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    hud.bezelView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    hud.label.text = text;
    hud.label.textColor = [UIColor darkTextColor];
    [hud showAnimated:YES];
}

- (void)hiddenWaitAnimation
{
    MBProgressHUD* hud = (MBProgressHUD*)[self.view viewWithTag:888];
    if(hud != nil)
    {
        [hud hideAnimated:YES];
        [hud removeFromSuperview];
    }
}



@end

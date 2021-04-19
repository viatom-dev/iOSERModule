//
//  ViaReportWave.m
//  ViHealth
//
//  Created by Viatom on 2019/6/5.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "ViaReportWave.h"

@interface ViaReportWave ()

@property (nonatomic, copy) NSArray *waveArr;
@property (nonatomic, assign) NSRange range;    // 波形范围
@property (nonatomic, assign) int points_per_ms;     // 每一秒的点数
@property (nonatomic, assign) int waveRow;   // 当前报告页绘制波形的行数
@property (nonatomic, assign) float waveRuler;
@property (nonatomic, assign) CGFloat scale;

@end

@implementation ViaReportWave {
    //  边框4个点
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    CGPoint point4;
    
    float w_per_val; // 每个值的宽度
}

- (instancetype)initWithFrame:(CGRect)frame
                    waveArray:(NSArray *)arr
                        range:(NSRange)range
                           hz:(int)hz
                        ruler:(float)ruler
                        scale:(CGFloat)scale {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _waveArr = arr;
        _points_per_ms = hz;
        _waveRuler = ruler;
        _scale = scale;
        _waveRow = 1;
        self.range = range;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_waveArr.count == 0) {   //如果spc没有测量心电
        return;
    }
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    [self drawRectangle];
    [self drawThinLines];
    [self drawThickLines];
    [self drawScaleplate];    //画标尺
    [self drawEcgWave];
}

//画波形外框
- (void)drawRectangle {

    point1 = CGPointMake(1, viapadding);
    point2 = CGPointMake(wave_width + viapadding, point1.y);
    
    point3 = CGPointMake(point2.x, _waveRow * H_PER_ROW + point1.y); // 每一行波形 对应五格
    point4 = CGPointMake(point1.x, point3.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point1];
    [[UIColor lightGrayColor] setStroke];
    path.lineWidth = thickLineW;
    [path stroke];
}

//画细线
- (void)drawThinLines {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //纵细线
    for (float i = point1.x; i <= point2.x; i += point_per_mm) {
        CGPoint verticalPointStart = CGPointMake(i, point1.y);
        CGPoint verticalPointEnd = CGPointMake(verticalPointStart.x, point3.y);
        [path moveToPoint:verticalPointStart];
        [path addLineToPoint:verticalPointEnd];
    }
    //横细线
    for (float i = point1.y; i <= point4.y; i += point_per_mm) {
        CGPoint horizonPointStart = CGPointMake(point1.x, i);
        CGPoint horizonPointEnd = CGPointMake(point2.x, horizonPointStart.y);
        [path moveToPoint:horizonPointStart];
        [path addLineToPoint:horizonPointEnd];
    }
    path.lineWidth = thinLineW;
    [[UIColor colorWithRed:255.0/255 green:192.0/255 blue:223.0/255 alpha:1.0] setStroke];
    [path stroke];
    
}

//画粗线
- (void)drawThickLines {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //纵粗线
    for (float i = point1.x; i <= point2.x; i += 5*point_per_mm) {
        CGPoint verticalPointStart = CGPointMake(i, point1.y);
        CGPoint verticalPointEnd = CGPointMake(verticalPointStart.x, point3.y);
        [path moveToPoint:verticalPointStart];
        [path addLineToPoint:verticalPointEnd];
    }
    //横粗线
    for (float i = point1.y; i <= point4.y; i += 5*point_per_mm) {
        CGPoint horizonPointStart = CGPointMake(point1.x, i);
        CGPoint horizonPointEnd = CGPointMake(point2.x, horizonPointStart.y);
        [path moveToPoint:horizonPointStart];
        [path addLineToPoint:horizonPointEnd];
    }
    path.lineWidth = thickLineW;
    [[UIColor colorWithRed:255.0/255 green:122.0/255 blue:122.0/255 alpha:1.0] setStroke];
    [path stroke];
}

//画标尺
- (void)drawScaleplate {
    
    CGPoint startPoint = CGPointMake(point1.x, point1.y + upper_limit);
    CGPoint Point2 = CGPointMake(startPoint.x + point_per_mm, startPoint.y);
    CGPoint Point3 = CGPointMake(Point2.x, point1.y + 20 * point_per_mm);
    CGPoint Point4 = CGPointMake(Point3.x + 3 * point_per_mm, Point3.y);
    CGPoint Point5 = CGPointMake(Point4.x, startPoint.y);
    CGPoint endPoint = CGPointMake(point1.x + 5 * point_per_mm, startPoint.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:Point2];
    [path addLineToPoint:Point3];
    [path addLineToPoint:Point4];
    [path addLineToPoint:Point5];
    [path addLineToPoint:endPoint];
    path.lineWidth = thickLineW;
    [[UIColor blackColor] setStroke];
    [path stroke];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(point1.x, point1.y - viapadding * 0.8, wave_width, 5 * point_per_mm)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = [NSString stringWithFormat:@"时间: %@    %@", self.startTime, self.symptom];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:timeLabel];
    
    //标尺文字
    UILabel *mVlabel = [[UILabel alloc] initWithFrame:CGRectMake(point1.x, point1.y - viapadding * 0.8, wave_width, 5 * point_per_mm)];
    mVlabel.text = [NSString stringWithFormat:@"增益: %dmm/mV     走速: 25mm/s",(int)(10/_waveRuler)];
    mVlabel.font = [UIFont systemFontOfSize:10];
    mVlabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:mVlabel];
}

/******画波形*****/
- (void)drawEcgWave {
    int drawWaveRow = 0;
    int total_data_num = (int)_waveArr.count;
    if (total_data_num <= SEC_FIRSTROW * _points_per_ms) {
        drawWaveRow = 1;
    }else{
        int other_data_num = total_data_num - SEC_FIRSTROW * _points_per_ms;
        if (other_data_num % (SEC_PER_ROW * _points_per_ms) == 0) {
            drawWaveRow = other_data_num / (SEC_PER_ROW * _points_per_ms) + 1;
        }else{
             drawWaveRow = other_data_num / (SEC_PER_ROW * _points_per_ms) + 2;
        }
    }
    w_per_val = point_per_mm / (_points_per_ms/mm_per_second);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect waveRect;
    NSArray *arrDraw;
    NSRange range = NSMakeRange(0, 0);
    //波形,画第一行
    int num_first_row = SEC_FIRSTROW * _points_per_ms;
//    int num_each_time = SEC_PER_ROW*_points_per_ms;
    int length = 0 ;
    int index_l =  0;
    length = MIN(num_first_row, total_data_num);
    range = NSMakeRange(index_l ,length);
    arrDraw = [_waveArr subarrayWithRange:range];
    waveRect = CGRectMake(point1.x + 5*point_per_mm, point1.y, point2.x-point1.x,(upper_limit+lower_limit));
    [self drawWaveInContext:context rect:waveRect valueArr:_waveArr];
    //画剩余的行
//    for(int i = 1;i < drawWaveRow ; i++){
//        index_l = num_first_row + (i - 1) * num_each_time;
//        length = MIN(num_each_time, total_data_num - index_l);
//        range = NSMakeRange(index_l ,length);
//        arrDraw = [_waveArr subarrayWithRange:range];
//        waveRect = CGRectMake(point1.x,i*(upper_limit+lower_limit) + point1.y, point2.x-point1.x,(upper_limit+lower_limit));
//        [self drawWaveInContext:context rect:waveRect valueArr:arrDraw];
//    }
}

- (void)drawWaveInContext:(CGContextRef)context rect:(CGRect)rect valueArr:(NSArray *)valueArr {
    if (valueArr.count <= 0) { return; }
    CGContextBeginPath(context);
    BOOL isInvalid = YES;
    NSInteger lastLocation = 0; CGFloat offsetX = 0;
    for (NSUInteger i = self.range.location; i < self.range.location + self.range.length; i++) {
        double ecgVal = [[valueArr objectAtIndex:i] doubleValue] / self.scale;
        CGPoint point = CGPointMake(rect.origin.x + w_per_val*(i-self.range.location), rect.origin.y + upper_limit - ecgVal*(points_per_mV/_waveRuler));
        if (isInvalid) {
            isInvalid = NO;
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        
        
        if ([self.tagLocations containsObject:[NSString stringWithFormat:@"%ld", i]]) {
            NSString *indexStr = [NSString stringWithFormat:@"%ld", i];
            NSInteger index = [self.tagLocations indexOfObject:indexStr];
            NSString *tagStr = self.ecgTagArr[index];
            CGSize size = [self sizeFromText:tagStr width:CGFLOAT_MAX andFont:[UIFont systemFontOfSize:8]];
            [tagStr drawAtPoint:CGPointMake(point.x - size.width*0.5, rect.origin.y) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:8], NSForegroundColorAttributeName: [UIColor blackColor]}];
            
            // 计算并绘制RR间期和心率
            if (lastLocation != 0) {
                CGFloat x = ((point.x - size.width*0.5) + offsetX) * 0.5;
                NSInteger rrPeriod = (indexStr.integerValue - lastLocation) * 8.0;
                NSString *rrPeriodStr = [NSString stringWithFormat:@"%ld", rrPeriod];
                CGSize size = [self sizeFromText:rrPeriodStr width:CGFLOAT_MAX andFont:[UIFont systemFontOfSize:8]];
                [rrPeriodStr drawAtPoint:CGPointMake(x - size.width*0.5, rect.origin.y + 16) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:8], NSForegroundColorAttributeName: [UIColor blackColor]}];
                
                NSInteger hr = 60 / (rrPeriod / 1000.0);
                NSString *hrString = [NSString stringWithFormat:@"%ld", hr];
                CGSize HRsize = [self sizeFromText:hrString width:CGFLOAT_MAX andFont:[UIFont systemFontOfSize:8]];
                [hrString drawAtPoint:CGPointMake(x - HRsize.width*0.5, rect.origin.y) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:8], NSForegroundColorAttributeName: [UIColor blackColor]}];
            }
            lastLocation = indexStr.integerValue;
            offsetX = (point.x + size.width*0.5);
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawLabels {
    
}

- (CGSize)sizeFromText:(NSString *)text width:(CGFloat)width andFont:(UIFont *)font{
    CGRect r = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                 options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{NSFontAttributeName:font}
                                 context:nil];
    return r.size;
}

@end

//
//  UIBatteryView.m
//  Battry
//
//  Created by Chaos on 16/7/8.
//  Copyright © 2016年 Viatom. All rights reserved.
//

#import "UIBatteryView.h"

/*bat view*/

#define BATGreen RGBA(54, 216, 192, 1.0)
#define BATRed RGBA(230, 0, 8, 1.0)
#define BATDefault RGBA(35,35,35, 1.0)

@interface UIBatteryView()

@property (nonatomic , strong) NSTimer *timer;

@property (nonatomic, strong) CAShapeLayer *fillLayer;
@property (nonatomic, strong) CAShapeLayer *chargeLayer;

@property (nonatomic, assign) CGFloat currentBAT;  // 当前电量比例
@property (nonatomic, strong) NSString *curBatState;  //当前充电状态  //0 未充  1 充电未充满   2 充满
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat lowBatLine; // 低电量线

@property (nonatomic, strong) UILabel *batteryLabel;

@end


@implementation UIBatteryView {
    CGFloat _aWidth;
    CGFloat _aHeight;
    
    ///电池宽度
    CGFloat _bWidth;
    ///电池高度
    CGFloat _bHeight;
    ///电池外线宽
    CGFloat _bLineW;
    CGFloat bX ;
    ///y坐标
    CGFloat bY ;
    // 电池头的宽度
    CGFloat rW ;
    // 圆角
    CGFloat radius;
    
    CGFloat chargePercent;
}

- (instancetype)initWithPosition:(CGPoint)point
                     borderColor:(UIColor *)color
                      lowBattery:(CGFloat)low{
    self = [super init];
    if (self) {
        _borderColor = color;
        _lowBatLine = low;
        _aWidth = 36;
        _aHeight = 16;
        self.frame = CGRectMake(point.x, point.y - _aHeight*.5, _aWidth, _aHeight);
        [self initParams];
        [self drawBatteryBorder];
    }
    return self;
}

- (void)hiddenDetailLab{
    [self.batteryLabel removeFromSuperview];
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.50f target:self selector:@selector(charged) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)setCurBat:(CGFloat)curBat curState:(NSString *)state {
    
    _curBatState = state;
    if ([_curBatState isEqualToString:@"1"]) {
        if (!_timer) {
            [self drawChargeImage:YES];
            chargePercent = 0.0;
            [self.timer setFireDate:[NSDate distantPast]];
        }
        self.batteryLabel.hidden = YES;
    } else {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
            chargePercent = 0.0;
        }
        
        if ([_curBatState isEqualToString:@"2"]) {  //充满状态
            [self drawChargeImage:YES];
            _currentBAT = 1;//避免充电动画bug
            [self drawBatteryFill:_currentBAT];
        }else{         // 未充电状态
            [self drawChargeImage:NO];
            _currentBAT = curBat;//避免充电动画bug
            [self drawBatteryFill:_currentBAT];
        }
        self.batteryLabel.hidden = NO;
        self.batteryLabel.text = [NSString stringWithFormat:@"%d%%", (int)(curBat * 100)];
    }
}


- (void)charged {
    chargePercent += 0.2;
    if (chargePercent > 1.0) {
        chargePercent = 0.0;
    }
    [self drawBatteryFill:chargePercent];
}

- (CAShapeLayer *)fillLayer{
    if (!_fillLayer) {
        _fillLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_fillLayer];
    }
    return _fillLayer;
}

- (CAShapeLayer *)chargeLayer{
    if (!_chargeLayer) {
        _chargeLayer = [CAShapeLayer layer];
        _chargeLayer.fillColor = _chargIconColor ? _chargIconColor.CGColor : BATDefault.CGColor;
        _chargeLayer.strokeColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_chargeLayer];
    }
    return _chargeLayer;
}

- (void)initParams{
    // 给定默认值
    _currentBAT = 0.0;
    bX = bY = 1.0;
    radius = 2.0;
    rW = 3.0;
    _bLineW = 1;
    _bHeight = _aHeight - 2*bY;
    _bWidth = _aWidth - 2*bX - rW;
}

- (void)drawBatteryBorder{
    ///x坐标
    //画电池【左边电池】
    UIBezierPath *pathLeft = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(bX, bY, _bWidth, _bHeight) cornerRadius:radius];
    CAShapeLayer *batteryLayer = [CAShapeLayer layer];
    batteryLayer.lineWidth = _bLineW;
    batteryLayer.strokeColor = !_borderColor ? [UIColor whiteColor].CGColor : _borderColor.CGColor;
    batteryLayer.fillColor = [UIColor clearColor].CGColor;
    batteryLayer.path = [pathLeft CGPath];
    [self.layer addSublayer:batteryLayer];
    
    //画电池【右边电池箭头】
    UIBezierPath *pathRight = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_bWidth + bX*2, bY + _bHeight*.25, rW, _bHeight*.5)
                                                    byRoundingCorners:UIRectCornerBottomRight|UIRectCornerTopRight
                                                          cornerRadii:CGSizeMake(radius*1.5, radius*1.5)];
    CAShapeLayer *layerRight = [CAShapeLayer layer];
    layerRight.strokeColor = [UIColor clearColor].CGColor;
    layerRight.fillColor = !_borderColor ? [UIColor whiteColor].CGColor : _borderColor.CGColor;
    layerRight.path = [pathRight CGPath];
    [self.layer addSublayer:layerRight];
}

- (void)drawBatteryFill:(CGFloat)percent {
    [self fillLayer];
    CGFloat wFill = percent*(_bWidth - _bLineW * 2);
    UIBezierPath *pathFill = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(bX  + _bLineW, bY + _bLineW, wFill, _bHeight - _bLineW * 2) cornerRadius:radius];
    if ([_curBatState isEqualToString:@"1"]) {
        _fillLayer.fillColor = _fillColor ? _fillColor.CGColor : BATGreen.CGColor;
    }else{
        if (percent <= _lowBatLine || [_curBatState isEqualToString:@"3"]) {
            _fillLayer.fillColor = _lowColor ? _lowColor.CGColor : BATRed.CGColor;
        }else
            _fillLayer.fillColor = _fillColor ? _fillColor.CGColor : BATGreen.CGColor;
    }
    _fillLayer.path = [pathFill CGPath];
}

- (void)drawChargeImage:(BOOL)display{
    if (display) {
        // 定点 6个点
        CGFloat space1 = 3; // 两个中间点水平间隔
        CGFloat space2 = 8; // 两个峰点水平间隔
        CGPoint p1 = CGPointMake(_bWidth*0.20 + bX, _aHeight*.5);
        CGPoint p2 = CGPointMake(_bWidth*.5 + bX - space1*.5, _aHeight*.5);
        CGPoint p3 = CGPointMake(_bWidth*.5 + bX - space2*.5, _aHeight*0.15);
        CGPoint p4 = CGPointMake(_bWidth*0.8 + bX, _aHeight*.5);
        CGPoint p5 = CGPointMake(_bWidth*.5 + bX + space1*.5, _aHeight*.5);
        CGPoint p6 = CGPointMake(_bWidth*.5 + bX + space2*.5, _aHeight*0.85);
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:p1];
        [path addLineToPoint:p2];
        [path addLineToPoint:p3];
        [path addLineToPoint:p4];
        [path addLineToPoint:p5];
        [path addLineToPoint:p6];
        self.chargeLayer.path = path.CGPath;
        self.chargeLayer.zPosition = 101;
        [self.chargeLayer setHidden:NO];
    }else{
        [self.chargeLayer setHidden:YES];
    }
}

- (UILabel *)batteryLabel {
    if (_batteryLabel == nil) {
        _batteryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _bWidth, _aHeight)];
//        _batteryLabel.center = self.center;
        _batteryLabel.text = @"100%";
        _batteryLabel.textColor = [UIColor whiteColor];
        _batteryLabel.font = [UIFont systemFontOfSize:11];
        _batteryLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_batteryLabel];
        
    }
    return _batteryLabel;
}

@end

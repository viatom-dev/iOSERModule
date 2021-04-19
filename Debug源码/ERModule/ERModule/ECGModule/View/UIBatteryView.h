//
//  UIBatteryView.h
//  Battry
//
//  Created by Chaos on 16/7/8.
//  Copyright © 2016年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBA(r,g,b,a)  [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

@interface UIBatteryView : UIView

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;


@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *lowColor;
@property (nonatomic, strong) UIColor *chargIconColor;

/**
 UIBatteryView 唯一的初始化方法
 @param point point.x 为电池起点位置  point.y 为电池中心位置
 @param color 电池边框以及充电标识颜色
 @param low 低电量标准 < low 为低电量
 @return 44*20 的电池
 */
- (instancetype)initWithPosition:(CGPoint)point
                     borderColor:(UIColor *)color
                      lowBattery:(CGFloat)low;

- (void)hiddenDetailLab;
- (void)setCurBat:(CGFloat)curBat curState:(NSString *)state;

@end

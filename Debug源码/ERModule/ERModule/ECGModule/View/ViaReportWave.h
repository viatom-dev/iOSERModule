//
//  ViaReportWave.h
//  ViHealth
//
//  Created by Viatom on 2019/6/5.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTMarco.h"



NS_ASSUME_NONNULL_BEGIN

@interface ViaReportWave : UIView

/** 心电标记数组*/
@property (nonatomic, strong) NSArray *ecgTagArr;
/** 心电标记下标数组*/
@property (nonatomic, strong) NSArray *tagLocations;
/** 心电片段开始时间*/
@property (nonatomic, copy) NSString *startTime;
/** 心电片段症状 */
@property (nonatomic, copy) NSString *symptom;


/**
 @param frame frame
 @param arr point array
 @param hz device hz
 @param ruler 1mV --> 高度变化
 @param scale 数据压缩比
 @return wave
 */
- (instancetype)initWithFrame:(CGRect)frame
                    waveArray:(NSArray *)arr
                        range:(NSRange)range
                           hz:(int)hz
                        ruler:(float)ruler
                        scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END

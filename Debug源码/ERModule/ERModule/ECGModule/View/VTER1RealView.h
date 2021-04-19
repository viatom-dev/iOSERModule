//
//  VTER1RealView.h
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    VTRecordStatusNotSupport = 301, // 状态不支持 录制
    VTRecordStatusStart,  //开始录制
    VTRecordStatusFailed,   //  录制过程中 状态改变 导致录制失败
    VTRecordStatusFinished,  // 无错误 即录制完成
} VTRecordStatus;


typedef void(^ViewReportHistory)(void);
typedef void(^RecordWave)(VTRecordStatus status, NSArray * _Nullable recordArray);

NS_ASSUME_NONNULL_BEGIN

@interface VTER1RealView : UIView

@property (nonatomic, copy) ViewReportHistory reportHandle;
@property (nonatomic, copy) RecordWave recordHandle;

@property (nonatomic, assign) u_short heartVal;
@property (nonatomic, assign) u_char runStatus;
@property (nonatomic, copy) NSArray *receiveArray;

@property (nonatomic, assign) BOOL isBackgroundMode;


- (void)recordInBackgroundMode;
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END

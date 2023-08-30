//
//  ERSyncManager.h
//  ERModule
//
//  Created by yangweichao on 2021/4/12.
//

#import <Foundation/Foundation.h>
@class ERRecordECG;

typedef enum: NSUInteger {
    AIStatusNotResp = 80000,    // AI分析未返回状态
    AIStatusFinshed ,           // AI分析完成
    AIStatusIng,                // AI分析中
    AIStatusError,              // 分析异常
    AIStatusFileNotUpload,      // 等待文件上传
    AIStatusOther,              // 其他异常
} AIStatus;

typedef void(^SyncEcgFileCallBack)(NSString * _Nullable msg, NSInteger code, NSDictionary * _Nullable response);

NS_ASSUME_NONNULL_BEGIN

@interface ERSyncManager : NSObject

+ (instancetype)sharedInstance;

+ (void)syncRecordEcg:(NSString *)recordFileUrl finished:(SyncEcgFileCallBack)callback;

- (void)commitECGRecord:(ERRecordECG *)ecgModel finished:(SyncEcgFileCallBack)callback;

@end

NS_ASSUME_NONNULL_END

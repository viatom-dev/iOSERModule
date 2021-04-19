//
//  ERSyncManager.h
//  ERModule
//
//  Created by yangweichao on 2021/4/12.
//

#import <Foundation/Foundation.h>

typedef void(^SyncEcgFileCallBack)(NSString * _Nullable msg, NSInteger code, NSDictionary * _Nullable response);

NS_ASSUME_NONNULL_BEGIN

@interface ERSyncManager : NSObject

+ (void)syncRecordEcg:(NSString *)recordFileUrl finished:(SyncEcgFileCallBack)callback;

@end

NS_ASSUME_NONNULL_END

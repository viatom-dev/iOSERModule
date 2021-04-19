//
//  VTCustomText.h
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import <Foundation/Foundation.h>
@class VTERUser;

NS_ASSUME_NONNULL_BEGIN

@interface VTCustomText : NSObject

/// @brief 默认为"设备"
@property (nonatomic, copy) NSString *deviceStr;

/// @brief 默认为"采集"
@property (nonatomic, copy) NSString *recordStr;


/// @brief 后台采集间隔 ，单位为秒，最小间隔为1分钟      默认30分钟
@property (nonatomic, assign) NSUInteger receiveInterval;

@property (nonatomic, strong) VTERUser *user;


+ (instancetype)sharedInstance;


@end

NS_ASSUME_NONNULL_END

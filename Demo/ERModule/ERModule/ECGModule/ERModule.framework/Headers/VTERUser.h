//
//  VTERUser.h
//  ERModule
//
//  Created by yangweichao on 2021/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VTERUser : NSObject

@property (nonatomic,copy)NSString *nickName;//昵称
@property (nonatomic,copy)NSString *gender;//性别 1：男；2：女
@property (nonatomic,copy)NSString *dateBirth;//出生年月日 yyyy-MM-dd
@property (nonatomic,copy)NSString *height;//身高 cm
@property (nonatomic,copy)NSString *weight;//体重 kg

@end

NS_ASSUME_NONNULL_END

//
//  VTERUser.h
//  ERModule
//
//  Created by yangweichao on 2021/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VTERUser : NSObject

/// 昵称
@property (nonatomic,copy) NSString *nickName;

/// 性别 1：男；2：女
@property (nonatomic,copy) NSString *gender;

/// 出生年月日 yyyy-MM-dd
@property (nonatomic,copy) NSString *dateBirth;

/// 手机号码
@property (nonatomic,copy) NSString *phone;

/// 身份证号码
@property (nonatomic,copy) NSString *idcard;

@property (nonatomic,copy)NSString *height;//身高
@property (nonatomic,copy)NSString *weight;//体重

@end

NS_ASSUME_NONNULL_END

//
//  VTMBLEReceive.h
//  VTMProductDemo
//
//  Created by viatom on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "VTMBLEEnum.h"

typedef void(^VTMBLEResponse)(u_char cmd, VTMBLEPkgType type, NSData *_Nullable response);

NS_ASSUME_NONNULL_BEGIN

@interface VTMBLEReceive : NSObject

@property (nonatomic, assign) u_char cmd;
@property (nonatomic, assign) VTMBLEPkgType type;
@property (nonatomic, copy) NSData * _Nullable response;

+ (void)receiveData:(NSData *)data parseResult:(VTMBLEResponse)response;

+ (instancetype)modelWithReceiveData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

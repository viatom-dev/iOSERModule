//
//  VTCustomText.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import "VTCustomText.h"
#import "VTERUser.h"

@implementation VTCustomText

static VTCustomText *_instance = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        [_instance initText];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [VTCustomText sharedInstance];
}
-(id)copyWithZone:(NSZone *)zone{
    return [VTCustomText sharedInstance];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [VTCustomText sharedInstance];
}


- (void)initText{
    _deviceStr = @"设备";
    _recordStr = @"采集";
    _receiveInterval = 1*60;
}


- (void)setDeviceStr:(NSString *)deviceStr{
    _deviceStr = deviceStr;
}

- (void)setRecordStr:(NSString *)recordStr{
    _recordStr = recordStr;
}

- (void)setReceiveInterval:(NSUInteger)receiveInterval{
    if (receiveInterval < 60) {
        _receiveInterval = 60;
    }else{
        _receiveInterval = receiveInterval;
    }
}

@end

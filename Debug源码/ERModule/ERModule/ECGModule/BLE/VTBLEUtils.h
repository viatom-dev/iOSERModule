//
//  VTBLEUtils.h
//  VTO2Lib
//
//  Created by viatom on 2020/6/23.
//  Copyright © 2020 viatom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTDevice.h"

#ifdef DEBUG
    #define DLog( s, ... ) NSLog( @"<%@,(line=%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
    #define DLog( s, ... )
#endif

typedef NS_ENUM(NSInteger, VTBLEState) {
    VTBLEStateUnknown = 0,
    VTBLEStateResetting,
    VTBLEStateUnsupported,
    VTBLEStateUnauthorized,
    VTBLEStatePoweredOff,
    VTBLEStatePoweredOn,
    VTBLEStateNotOpen,
};

NS_ASSUME_NONNULL_BEGIN

@protocol VTBLEUtilsDelegate <NSObject>

@optional
- (void)updateBleState:(VTBLEState)state;

- (void)scanCompletion;

- (void)didDiscoverDevice:(VTDevice *)device;

- (void)didConnectedDevice:(VTDevice *)device;

/// @brief This device has been disconnected. Note: If error == nil ，user cancel connection .
- (void)didDisconnectedDevice:(VTDevice *)device andError:(NSError *)error;

@end


@interface VTBLEUtils : NSObject<CBCentralManagerDelegate>

@property (nonatomic, strong) VTDevice *device;
@property (nonatomic, strong) NSMutableArray *deviceArray;

/// @brief Whether to enable the automatic reconnection function.   default YES.
@property (nonatomic, assign) BOOL isAutoReconnect;

@property (nonatomic, assign) id <VTBLEUtilsDelegate> delegate; 

+ (instancetype)sharedInstance;

- (VTBLEState)bleState;

- (void)createBleManager;

- (void)startScanWithTime:(NSUInteger)sec;

- (void)stopScan;

- (void)connectToDevices:(NSArray <VTDevice *> *)devices;

- (void)cancelConnect:(VTDevice *)device;

@end

NS_ASSUME_NONNULL_END

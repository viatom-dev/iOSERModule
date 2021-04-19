//
//  VTBLEUtils.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/23.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTBLEUtils.h"

@interface VTBLEUtils ()

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) CBPeripheral *selectedPeripheral;

@end


@implementation VTBLEUtils

static VTBLEUtils *_utils = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utils = [[super allocWithZone:NULL] init];
    });
    return _utils;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [VTBLEUtils sharedInstance];
}
-(id)copyWithZone:(NSZone *)zone{
    return [VTBLEUtils sharedInstance];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [VTBLEUtils sharedInstance];
}

#pragma mark ----------------------------


- (void)setIsAutoReconnect:(BOOL)isAutoReconnect{
    _isAutoReconnect = isAutoReconnect;
}

- (NSMutableArray *)deviceArray{
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceArray;
}

#pragma mark ---- private methods ----

- (void)createBleManager{
    _isAutoReconnect = YES;
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (NSArray *)retriveConnectedPeriphral{
    NSArray *ps = [_centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"14839AC4-7D7E-415C-9A42-167340CF2339"]]];
    return ps;
}

- (VTBLEState)bleState{
    if (!_centralManager) {
        return VTBLEStateNotOpen;
    }
    NSInteger state = _centralManager.state;
    return state;
}

- (void)startScanWithTime:(NSUInteger)sec{
    if (_centralManager.state != 5) {
        return;
    }
    [self startScan];
    [self performSelector:@selector(scanTimeout) withObject:nil afterDelay:sec];
}

- (void)startScan{
    if (_centralManager.state != 5) {
        return;
    }
    [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
}

- (void)scanTimeout{
    [self stopScan];
    if (_delegate && [_delegate respondsToSelector:@selector(scanCompletion)]) {
        [_delegate scanCompletion];
    }
}

- (void)stopScan{
    [_centralManager stopScan];
}

- (void)connectToDevices:(NSArray <VTDevice *> *)devices{
    [self stopScan];
    if (devices.count != 0) {
        [self.deviceArray addObjectsFromArray:devices];
        for (int i = 0; i < devices.count; i ++) {
            CBPeripheral *p = [devices[i] rawPeripheral];
            [_centralManager connectPeripheral:p options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
        }
    }
}

- (void)cancelConnect:(VTDevice *)device{
    if (device) {
        [_centralManager cancelPeripheralConnection:device.rawPeripheral];
    }
}


#pragma mark ---- CBCentralManagerDelegate ----
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSInteger state = central.state;
    if (_delegate && [_delegate respondsToSelector:@selector(updateBleState:)]) {
        [_delegate updateBleState:state];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    VTDevice *device = [[VTDevice alloc] initWithPeripheral:peripheral adv:advertisementData RSSI:RSSI];
    if (!device) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didDiscoverDevice:)]) {
        [_delegate didDiscoverDevice:device];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    VTDevice *targetDevice = _device;
    if (_deviceArray.count != 0) {
        for (VTDevice *d in _deviceArray) {
            if ([d.advName isEqualToString:peripheral.name]) {
                targetDevice = d;
                break;
            }
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectedDevice:)]) {
        [_delegate didConnectedDevice:targetDevice];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    VTDevice *targetDevice = _device;
    if (_deviceArray.count != 0) {
        for (VTDevice *d in _deviceArray) {
            if ([d.advName isEqualToString:peripheral.name]) {
                targetDevice = d;
                break;
            }
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectedDevice:andError:)]) {
        [_delegate didDisconnectedDevice:targetDevice andError:error];
    }
    if (error) {
        DLog(@"failed to connect : %@, (%@)", peripheral, error.localizedDescription);
        if (_isAutoReconnect) {
            [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
        }
    }else{
        if (_deviceArray.count != 0) [_deviceArray removeObject:targetDevice];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    DLog(@"failed to connect : %@, (%@)", peripheral, error.localizedDescription);
}


@end

//
//  VTMURATUtils
//  ViHealth
//
//  Created by Viatom on 2018/6/5.
//  Copyright © 2018年 Viatom. All rights reserved.
//

#import "VTMURATUtils.h"
#import "VTMBLESend.h"
#import "VTMBLEReceive.h"

typedef enum : NSUInteger {
    BLERequestTimeoutNormal = 3000,
    BLERequestTimeoutFactory = 1000,
    BLERequestTimeoutRealData = 490,
} BLERequestTimeout;

#ifdef  DEBUG
#define VTMLog( s, ... )   NSLog( @"<%@,(line=%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define VTMLog( s, ... )
#endif

@interface VTMURATUtils ()<CBPeripheralDelegate>

@property (nonatomic, strong) NSMutableData *dataPool;

@property (nonatomic, assign) VTMDeviceType type;

@property (nonatomic, strong) CBCharacteristic *notifyHRCharacteristic;
/// Characteristic value  for write
@property (nonatomic, strong) CBCharacteristic *rxcharacteristic;
/// Characteristic value  for write
@property (nonatomic, strong) CBCharacteristic *txcharacteristic;

@property (nonatomic, strong) CBService *hrService;

@property (nonatomic, assign) VTMRate defaultRate;

@end

@implementation VTMURATUtils{
    u_int via_pkg_length;
    u_char via_cmd_type;
    dispatch_queue_t requestQueue;
}

- (instancetype)initWithDevice:(CBPeripheral *)device deviceDelegate:(id)target{
    self = [super init];
    if (self) {
        self.dataPool = [NSMutableData dataWithCapacity:10];
        self.deviceDelegate = target;
        self.peripheral = device;
        requestQueue = dispatch_queue_create("ble.requestQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.dataPool = [NSMutableData dataWithCapacity:10];
        requestQueue = dispatch_queue_create("ble.requestQueue", DISPATCH_QUEUE_SERIAL);
        self.mtu = 20;
    }
    return self;
}

- (VTMRate)defaultRate{
    VTMRate rate;
    rate.rate = 125;
    return rate;
}


- (void)setPeripheral:(CBPeripheral *)peripheral{
//    if (_peripheral != peripheral) {
//        _peripheral = nil;
        _peripheral = peripheral;
        [self deployServicesAndCharacterists];
//    }
}

- (void)setNotifyDeviceRSSI:(BOOL)notifyDeviceRSSI{
    _notifyDeviceRSSI = notifyDeviceRSSI;
    [self readRSSI];
}

- (void)setMtu:(NSUInteger)mtu{
    _mtu = mtu;
}

#pragma mark -- class methods

- (void)requestDeviceInfo{
    NSData *buf = [VTMBLESend getDeviceInfo];
    via_cmd_type = VTMBLECmdGetDeviceInfo;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)requestBatteryInfo{
    NSData *buf = [VTMBLESend getBattery];
    via_cmd_type = VTMBLECmdGetBattery;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)syncTime:(NSDate *)date{
    if (date == nil) date = [NSDate date];
    VTMDeviceTime time;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:date];
    time.year = cp.year;
    time.month = cp.month;
    time.day = cp.day;
    time.hour = cp.hour;
    time.minute = cp.minute;
    time.second = cp.second;
    NSData *buf = [VTMBLESend syncDeviceTime:time];
    via_cmd_type = VTMBLECmdSyncTime;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)requestFilelist{
    NSData *buf = [VTMBLESend getFileList];
    via_cmd_type = VTMBLECmdGetFileList;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)prepareReadFile:(NSString *)fileName{
    VTMOpenFile of;
    strcpy(of.file_name, [fileName cStringUsingEncoding:NSASCIIStringEncoding]);
    of.file_offset = 0;
    NSData *buf = [VTMBLESend startReadFile:of];
    via_cmd_type = VTMBLECmdStartRead;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)readFile:(u_int)offset{
    VTMReadFile rf;
    rf.addr_offset = offset;
    NSData *buf = [VTMBLESend readFile:rf];
    via_cmd_type = VTMBLECmdReadFile;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)endReadFile{
    NSData *buf = [VTMBLESend endReadFile];
    via_cmd_type = VTMBLECmdEndRead;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)factoryReset{
    NSData *buf = [VTMBLESend restoreFactory];
    via_cmd_type = VTMBLECmdRestore;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)productReset{
    NSData *buf = [VTMBLESend productReset];
    via_cmd_type = VTMBLECmdProductReset;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}

- (void)factorySet:(VTMConfig)config{
    NSData *buf = [VTMBLESend factoryConfig:config];
    via_cmd_type = VTMBLECmdRestoreInfo;
    [self sendCmdWithData:buf Delay:BLERequestTimeoutNormal];
}


#pragma mark --
/**
 receive data from periphral

 @param data data from periphral
 */
- (void)didReceiveData:(NSData *)data{
    [_dataPool appendData:data];
    Byte *buf = (Byte *)_dataPool.bytes;
    NSInteger len = _dataPool.length;
    if (buf[0] != 0xA5) {
        int i = 1;
        for (; i < len; i ++) {
            if (buf[i] == 0xA5) { // 取到下一个正确的A5位置
                break;
            }
        }
        // 清空下一个包头之前的错误数据
        [_dataPool replaceBytesInRange:NSMakeRange(0, i) withBytes:NULL length:0];
        return;
    }else if (len < 7) {
        return;
    }
    via_pkg_length = *((u_short *)&buf[5]) + 8;
    if (len < via_pkg_length) {
        return;
    }
    NSData *responseData = [_dataPool subdataWithRange:NSMakeRange(0, via_pkg_length)];
    [_dataPool replaceBytesInRange:NSMakeRange(0, via_pkg_length) withBytes:NULL length:0];
    [self parseResponseData:responseData];
}



#pragma mark - 处理回应包
- (void)parseResponseData:(NSData *)buf{
    __weak typeof(self) weakSelf = self;
//    VTMLog(@"Response data : %@", buf);
    [VTMBLEReceive receiveData:buf parseResult:^(u_char cmd, VTMBLEPkgType type, NSData * _Nullable response) {
        [weakSelf callback:cmd type:type data:response];
    }];
}

- (void)callback:(u_char)cmd type:(VTMBLEPkgType)type data:(NSData *)response{
    if (type != VTMBLEPkgTypeNormal) {
        if (_delegate && [_delegate respondsToSelector:@selector(util:commandFailed:deviceType:failedType:)]) {
            [_delegate util:self commandFailed:cmd deviceType:_type failedType:type];
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(util:commandCompletion:deviceType:response:)]) {
            [_delegate util:self commandCompletion:cmd deviceType:_type response:response];
        }
    }
}


#pragma mark - 底层读写函数
//中心设备与外设之间通信   通过NSData类型数据进行通讯   cmd
-(void)sendCmdWithData:(NSData *)cmd Delay:(int)delay{
    dispatch_async(requestQueue, ^{
//        VTMLog(@"Send cmd: %@", cmd);
        for (int i=0; i*self->_mtu < cmd.length; i++) {
            if (i > 0) {
                sleep(0.2);
            }
            NSRange range = {i*self->_mtu,((i+1)*self->_mtu) < cmd.length ? self->_mtu : cmd.length-i*self->_mtu};
            NSData* subCMD = [cmd subdataWithRange:range];
            // 多连接情况下,代理可能为空 (暂未分析出具体原因, 先行处理)
            if (self.peripheral.delegate == nil) {
                self.peripheral.delegate = self;
            }
            //写数据
            if (self.peripheral.state == CBPeripheralStateConnected) {
                [self.peripheral writeValue:subCMD forCharacteristic:self.txcharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
        }
    });
}


#pragma mark ---  uuid s

#define kVTMUartServiceUUID [CBUUID UUIDWithString:@"569a1101-b87f-490c-92cb-11ba5ea5167c"]
#define kVTMDevServiceUUID [CBUUID UUIDWithString:@"14839ac4-7d7e-415c-9a42-167340cf2339"]
#define kVTMTxCharacteristicUUID [CBUUID UUIDWithString:@"569a2001-b87f-490c-92cb-11ba5ea5167c"]
#define kVTMDevTxCharacteristicUUID [CBUUID UUIDWithString:@"8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"]
#define kVTMRxCharacteristicUUID [CBUUID UUIDWithString:@"569a2000-b87f-490c-92cb-11ba5ea5167c"]
#define kVTMDevRxCharacteristicUUID [CBUUID UUIDWithString:@"0734594A-A8E7-4B1A-A6B1-CD5243059A57"]
#define kVTMDeviceInformationServiceUUID [CBUUID UUIDWithString:@"180A"]
#define kVTMHardwareRevisionStringUUID [CBUUID UUIDWithString:@"2A27"]
#define kVTMHeartRateServiceUUID [CBUUID UUIDWithString:@"180D"]
#define kVTMHeartRateCharacteristic [CBUUID UUIDWithString:@"2A37"]


- (void)deployServicesAndCharacterists{
    _rxcharacteristic = nil;
    _txcharacteristic = nil;
    _notifyHRCharacteristic = nil;
    _peripheral.delegate = self;
    _dataPool = nil;
    _dataPool = [NSMutableData dataWithCapacity:10];
    [_peripheral discoverServices:@[kVTMUartServiceUUID, kVTMDevServiceUUID, kVTMDeviceInformationServiceUUID,kVTMHeartRateServiceUUID]];
}

- (void)readRSSI{
    _peripheral.delegate = self;
    [_peripheral readRSSI];
}

#pragma mark ---  periphral delegate

//***************************** 连接部分  ********************************************
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    VTMLog(@"%s", __func__);
    if (error)
    {
        if (_deviceDelegate && [_deviceDelegate respondsToSelector:@selector(utilDeployFailed:)]) {
            [_deviceDelegate utilDeployFailed:self];
        }
        VTMLog(@"Error discovering services: %@", error.localizedDescription);
        return;
    }
    NSArray *uuidArr = [[peripheral services] valueForKeyPath:@"@unionOfObjects.UUID"];
    if (![uuidArr containsObject:kVTMUartServiceUUID] &&
        ![uuidArr containsObject:kVTMDevServiceUUID]) {
        if (_deviceDelegate && [_deviceDelegate respondsToSelector:@selector(utilDeployFailed:)]) {
            [_deviceDelegate utilDeployFailed:self];
        }
        return;
    }
    for (CBService *s in [peripheral services])
    {
        if ([s.UUID isEqual:kVTMUartServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[kVTMTxCharacteristicUUID, kVTMRxCharacteristicUUID] forService:s];
        }
        else if ([s.UUID isEqual:kVTMDeviceInformationServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[kVTMHardwareRevisionStringUUID] forService:s];
        }
        else if ([s.UUID isEqual:kVTMDevServiceUUID])
        {
            [self.peripheral discoverCharacteristics:@[kVTMDevTxCharacteristicUUID, kVTMDevRxCharacteristicUUID] forService:s];
        }else if ([s.UUID isEqual:kVTMHeartRateServiceUUID]){
            _hrService = s;
            [self.peripheral discoverCharacteristics:nil forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    VTMLog(@"%s", __func__);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    VTMLog(@"%s", __func__);
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        VTMLog(@"Error discovering characteristics: %@", error.localizedDescription);
        return;
    }
    if(!_rxcharacteristic || !_txcharacteristic)
    {
        for (CBCharacteristic *c in [service characteristics])
        {
            if ([c.UUID isEqual:kVTMRxCharacteristicUUID] ||
                [c.UUID isEqual:kVTMDevRxCharacteristicUUID])
            {
                _rxcharacteristic = c;
                [_peripheral setNotifyValue:YES forCharacteristic:_rxcharacteristic];
                
            }else if ([c.UUID isEqual:kVTMTxCharacteristicUUID] ||
                      [c.UUID isEqual:kVTMDevTxCharacteristicUUID]) {
                _txcharacteristic = c;
            }else if ([c.UUID isEqual:kVTMHeartRateCharacteristic]){
                _notifyHRCharacteristic = c;
            }
        }
        if(_rxcharacteristic && _txcharacteristic){
            if (_deviceDelegate && [_deviceDelegate respondsToSelector:@selector(utilDeployCompletion:)]) {
                [_deviceDelegate utilDeployCompletion:self];
            }
        }
    }
}
//************************************************************************************

#pragma mark - 数据传输的重要部分
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error)
    {
        VTMLog(@"%@",error.localizedDescription);
        return;
    }
    
    
    if (characteristic == _rxcharacteristic)
    {
       
        [self didReceiveData:characteristic.value];
    }else if (characteristic == _notifyHRCharacteristic){
        if (_notifyHeartRate) {
            Byte *hrByte = (Byte *)characteristic.value.bytes;
            Byte hr = (hrByte[1] >= 30 && hrByte[1] <= 250) ? hrByte[1] : 0; // 取后一位
            if (_delegate && [_delegate respondsToSelector:@selector(receiveHeartRateByStandardService:)]) {
                [_delegate receiveHeartRateByStandardService:hr];
            }
        }
    }
    else if ([characteristic.UUID isEqual:kVTMHardwareRevisionStringUUID])
    {
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    if (_notifyDeviceRSSI) {
        if (_deviceDelegate && [_deviceDelegate respondsToSelector:@selector(util:updateDeviceRSSI:)]) {
            [_deviceDelegate util:self updateDeviceRSSI:RSSI];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        return;
    }

}

@end

@implementation VTMURATUtils (ECG)

- (void)requestECGConfig{
    NSData *data = [VTMBLESend getECGConfig];
    via_cmd_type = VTMECGCmdGetConfig;
    _type = VTMDeviceTypeECG;
    [self sendCmdWithData:data Delay:BLERequestTimeoutNormal];
}

- (void)requestECGRealData{
    NSData *data = [VTMBLESend getECGRealTimeData:self.defaultRate];
    via_cmd_type = VTMECGCmdGetRealData;
    _type = VTMDeviceTypeECG;
    [self sendCmdWithData:data Delay:BLERequestTimeoutRealData];
}

- (void)syncER1Config:(VTMER1Config)config{
    NSData *data = [VTMBLESend setER1Config:config];
    via_cmd_type = VTMECGCmdSetConfig;
    _type = VTMDeviceTypeECG;
    [self sendCmdWithData:data Delay:BLERequestTimeoutRealData];
}

- (void)syncER2Config:(VTMER2Config)config{
    NSData *data = [VTMBLESend setER2Config:config];
    via_cmd_type = VTMECGCmdSetConfig;
    _type = VTMDeviceTypeECG;
    [self sendCmdWithData:data Delay:BLERequestTimeoutRealData];
}

@end






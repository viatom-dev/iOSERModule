//
//  VTMBLESend.h
//  VTMProductDemo
//
//  Created by viatom on 2020/10/28.
//

#import <Foundation/Foundation.h>
#import "VTMBLEStruct.h"

NS_ASSUME_NONNULL_BEGIN

@interface VTMBLESend : NSObject
#pragma mark --- common

+ (NSData *)echoWithData:(NSData *)data;

+ (NSData *)getDeviceInfo;

+ (NSData *)deviceReset;

+ (NSData *)restoreFactory;

+ (NSData *)productReset;

+ (NSData *)getBattery;

//+ (NSData *)startFirmwareUpdate:(VTMStartFirmwareUpdate)param;
//
//+ (NSData *)updatingFirmware:(VTMFirmwareUpdate)param;
//
//+ (NSData *)endFirmwareUpdate;
//
//+ (NSData *)startLanguageUpdate:(VTMStartLanguageUpdate)param;
//
//+ (NSData *)updatingLanguage:(VTMLanguageUpdate)param;
//
//+ (NSData *)endLanguageUpdate;

+ (NSData *)factoryConfig:(VTMConfig)param;
//
//+ (NSData *)encrypt;

+ (NSData *)syncDeviceTime:(VTMDeviceTime)param;

//+ (NSData *)getDevicTemp;

+ (NSData *)getFileList;

+ (NSData *)startReadFile:(VTMOpenFile)param;

+ (NSData *)readFile:(VTMReadFile)param;

+ (NSData *)endReadFile;

//+ (NSData *)startWriteFile;
//
//+ (NSData *)writeFile:(VTMOpenFile)param;
//
//+ (NSData *)endWriteFile;

//+ (NSData *)deleteFile:(NSString *)fileName;

//+ (NSData *)getUserList;
//
//+ (NSData *)enterDfuMode;

@end

@interface VTMBLESend (ECG)

#pragma mark --- ECG

+ (NSData *)getECGConfig;

+ (NSData *)getECGRealTimeWaveForm:(VTMRate)rate;

+ (NSData *)getECGRealTimeData:(VTMRate)rate;

#pragma mark ------ ER1/VBeat
+ (NSData *)setER1Config:(VTMER1Config)config;

#pragma mark ------ ER2/DuoEK
+ (NSData *)setER2Config:(VTMER2Config)config;

@end


NS_ASSUME_NONNULL_END

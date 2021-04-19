//
//  VTMBLEParser.h
//  VTMProductDemo
//
//  Created by viatom on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "VTMBLEStruct.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief support for all viatom devices.
@interface VTMBLEParser : NSObject

+ (VTMDeviceInfo)parseDeviceInfo:(NSData *)data;

+ (VTMBatteryInfo)parseBatteryInfo:(NSData *)data;

//+ (VTMTemperature)parseTemperature:(NSData *)data;

+ (VTMFileList)parseFileList:(NSData *)data;

+ (VTMOpenFileReturn)parseFileLength:(NSData *)data;

+ (VTMFileData)parseFileData:(NSData *)data;

//+ (VTMUserList)parseUserList:(NSData *)data;


@end

/// @brief support for series of ecg.
@interface VTMBLEParser (ECG)

// All ecg product.
+ (void)parseWaveHeadAndTail:(NSData *)data result:(void(^)(VTMFileHead head, VTMER2FileTail tail))finished;

+ (float)mVFromShort:(short)n;

+ (VTMRunStatus)parseStatus:(u_char)status;

+ (VTMFlagDetail)parseFlag:(u_char)flag;

+ (VTMRealTimeWF)parseRealTimeWaveform:(NSData *)data;

+ (VTMRealTimeData)parseRealTimeData:(NSData *)data;

#pragma mark --- VBeat

+ (NSArray *)parseVBeatWaveData:(NSData *)waveData;


#pragma mark -- config
#pragma mark --- ER1/VBeat

+ (VTMER1Config)parseER1Config:(NSData *)data;

#pragma mark --- ER2/DuoEK

+ (VTMER2Config)parseER2Config:(NSData *)data;

@end



NS_ASSUME_NONNULL_END

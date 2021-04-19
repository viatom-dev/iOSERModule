//
//  VTMBLESend.m
//  VTMProductDemo
//
//  Created by viatom on 2020/10/28.
//

#import "VTMBLESend.h"
#import "VTMBLEEnum.h"
#import "VTMCalibrate.h"

#define COMMON_LENGTH 8

@implementation VTMBLESend

#pragma mark --- common

+ (NSData *)echoWithData:(NSData *)data{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdEcho data:data pkgNum:0];
    return buf;
}

+ (NSData *)getDeviceInfo{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdGetDeviceInfo data:nil pkgNum:0];
    return buf;
}

+ (NSData *)deviceReset{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdReset data:nil pkgNum:0];
    return buf;
}

+ (NSData *)restoreFactory{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdRestore data:nil pkgNum:0];
    return buf;
}

+ (NSData *)productReset{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdProductReset data:nil pkgNum:0];
    return buf;
}

+ (NSData *)getBattery{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdGetBattery data:nil pkgNum:0];
    return buf;
}

//+ (NSData *)startFirmwareUpdate:(VTMStartFirmwareUpdate)param{
//    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMStartFirmwareUpdate)];
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdUpdateFirmware data:dataRes pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)updatingFirmware:(VTMFirmwareUpdate)param{
//    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMFirmwareUpdate)];
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdUpdateFirmwareData data:dataRes pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)endFirmwareUpdate{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdUpdateFirmwareEnd data:nil pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)startLanguageUpdate:(VTMStartLanguageUpdate)param{
//    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMStartLanguageUpdate)];
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdUpdateLangua data:dataRes pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)updatingLanguage:(VTMLanguageUpdate)param{
//    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMLanguageUpdate)];
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdUpdateLanguaData data:dataRes pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)endLanguageUpdate{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdUpdateLanguaEnd data:nil pkgNum:0];
//    return buf;
//}

+ (NSData *)factoryConfig:(VTMConfig)param{
    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMConfig)];
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdRestoreInfo data:dataRes pkgNum:0];
    return buf;
}
//
//+ (NSData *)encrypt{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdEncrypt data:nil pkgNum:0];
//    return buf;
//}

+ (NSData *)syncDeviceTime:(VTMDeviceTime)param{
    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMDeviceTime)];
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdSyncTime data:dataRes pkgNum:0];
    return buf;
}

//+ (NSData *)getDevicTemp{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdGetDeviceTemp data:nil pkgNum:0];
//    return buf;
//}

+ (NSData *)getFileList{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdGetFileList data:nil pkgNum:0];
    return buf;
}

+ (NSData *)startReadFile:(VTMOpenFile)param{
    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMOpenFile)];
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdStartRead data:dataRes pkgNum:0];
    return buf;
}

+ (NSData *)readFile:(VTMReadFile)param{
    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMReadFile)];
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdReadFile data:dataRes pkgNum:0];
    return buf;
}

+ (NSData *)endReadFile{
    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdEndRead data:nil pkgNum:0];
    return buf;
}

//+ (NSData *)startWriteFile{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdStartWrite data:nil pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)writeFile:(VTMOpenFile)param{
//    NSData *dataRes = [NSData dataWithBytes:&param length:sizeof(VTMOpenFile)];
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdEndWrite data:dataRes pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)endWriteFile{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdEndRead data:nil pkgNum:0];
//    return buf;
//}

//+ (NSData *)deleteFile:(NSString *)fileName{
//    NSData *dataRes =[fileName dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdDeleteFile data:dataRes pkgNum:0];
//    return buf;
//}

//+ (NSData *)getUserList{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdGetUserList data:nil pkgNum:0];
//    return buf;
//}
//
//+ (NSData *)enterDfuMode{
//    NSData *buf = [VTMBLESend cmdWithType:VTMBLECmdEnterDFU data:nil pkgNum:0];
//    return buf;
//}

#pragma mark ---- base

+ (nonnull NSData *)cmdWithType:(u_char)type data:(NSData *)data pkgNum:(int)pkgNum{
    u_char *dataBuf = (u_char *)data.bytes;
    int bufLength = (int)data.length + COMMON_LENGTH;
    u_char buf[bufLength];
    buf[0] = (u_char)VTMBLEHeaderDefault;
    buf[1] = (u_char)type;
    buf[2] = (u_char)~type;
    buf[3] = (u_char)VTMBLEPkgTypeRequest;
    buf[4] = (u_char)pkgNum;
    buf[5] = (u_char)data.length;
    buf[6] = (u_char)data.length >> 8;
    for (int i = 0; i < data.length; i ++) {
        buf[i+7] = dataBuf[i];
    }
    buf[bufLength-1] = [VTMCalibrate calCRC8:buf bufSize:bufLength-1];
    return [NSData dataWithBytes:buf length:bufLength];
}


@end

@implementation VTMBLESend (ECG)

#pragma mark --- ECG

+ (NSData *)getECGConfig{
    NSData *buf = [VTMBLESend cmdWithType:VTMECGCmdGetConfig data:nil pkgNum:0];
    return buf;
}

+ (NSData *)getECGRealTimeWaveForm:(VTMRate)rate{
    NSData *dataRes = [NSData dataWithBytes:&rate length:sizeof(VTMRate)];
    NSData *buf = [VTMBLESend cmdWithType:VTMECGCmdGetRealWave data:dataRes pkgNum:0];
    return buf;
}

+ (NSData *)getECGRealTimeData:(VTMRate)rate{
    NSData *dataRes = [NSData dataWithBytes:&rate length:sizeof(VTMRate)];
    NSData *buf = [VTMBLESend cmdWithType:VTMECGCmdGetRealData data:dataRes pkgNum:0];
    return buf;
}

#pragma mark ------ ER1/VBeat
+ (NSData *)setER1Config:(VTMER1Config)config{
    NSData *dataRes = [NSData dataWithBytes:&config length:sizeof(VTMER1Config)];
    NSData *buf = [VTMBLESend cmdWithType:VTMECGCmdSetConfig data:dataRes pkgNum:0];
    return buf;
}

#pragma mark ------ ER2/DuoEK
+ (NSData *)setER2Config:(VTMER2Config)config{
    NSData *dataRes = [NSData dataWithBytes:&config length:sizeof(VTMER2Config)];
    NSData *buf = [VTMBLESend cmdWithType:VTMECGCmdSetConfig data:dataRes pkgNum:0];
    return buf;
}


@end

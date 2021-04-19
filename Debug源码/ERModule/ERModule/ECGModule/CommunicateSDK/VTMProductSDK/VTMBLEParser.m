//
//  VTMBLEParser.m
//  VTMProductDemo
//
//  Created by viatom on 2020/10/29.
//

#import "VTMBLEParser.h"

@implementation VTMBLEParser

+ (VTMDeviceInfo)parseDeviceInfo:(NSData *)data{
    VTMDeviceInfo info;
    [data getBytes:&info length:sizeof(VTMDeviceInfo)];
    return info;
}

+ (VTMBatteryInfo)parseBatteryInfo:(NSData *)data{
    VTMBatteryInfo info;
    [data getBytes:&info length:sizeof(VTMBatteryInfo)];
    return info;
}

//+ (VTMTemperature)parseTemperature:(NSData *)data{
//    VTMTemperature info;
//    [data getBytes:&info length:sizeof(VTMTemperature)];
//    return info;
//}

+ (VTMFileList)parseFileList:(NSData *)data{
    VTMFileList list;
    [data getBytes:&list length:sizeof(VTMFileList)];
    return list;
}

+ (VTMOpenFileReturn)parseFileLength:(NSData *)data{
    VTMOpenFileReturn re;
    [data getBytes:&re length:sizeof(VTMOpenFileReturn)];
    return re;
}

+ (VTMFileData)parseFileData:(NSData *)data{
    VTMFileData fileData;
    [data getBytes:&fileData length:sizeof(VTMFileData)];
    return fileData;
}

//+ (VTMUserList)parseUserList:(NSData *)data{
//    VTMUserList list;
//    [data getBytes:&list length:data.length];
//    return list;
//}

@end


@implementation VTMBLEParser (ECG)
// All ecg product.
+ (void)parseWaveHeadAndTail:(NSData *)data result:(void(^)(VTMFileHead head, VTMER2FileTail tail))finished{
    VTMFileHead head; VTMER2FileTail tail;
    [data getBytes:&head range:NSMakeRange(0, sizeof(VTMFileHead))];
    [data getBytes:&tail range:NSMakeRange(data.length - sizeof(VTMER2FileTail), sizeof(VTMER2FileTail))];
    finished(head, tail);
}

+ (float)mVFromShort:(short)n{
    return n*0.002467;
}

+ (VTMRunStatus)parseStatus:(u_char)status{
    VTMRunStatus sta;
    sta.curStatus = status&0x0F;
    sta.preStatus = (status >> 4)&0x0F;
    return sta;
}

+ (VTMFlagDetail)parseFlag:(u_char)flag{
    VTMFlagDetail f;
    f.rMark = flag&0x01;
    f.signalWeak = (flag >> 1)&0x01;
    f.signalPoor = (flag >> 2)&0x01;
    f.batteryStatus = (flag >> 6)&0x03; // 取后两位
    return f;
}

+ (VTMRealTimeWF)parseRealTimeWaveform:(NSData *)data{
    VTMRealTimeWF rewf;
    [data getBytes:&rewf length:sizeof(VTMRealTimeWF)];
    return rewf;
}

+ (VTMRealTimeData)parseRealTimeData:(NSData *)data{
    VTMRealTimeData real;
    [data getBytes:&real length:sizeof(VTMRealTimeData)];
    return real;
}

#pragma mark --- VBeat

+ (NSArray *)parseVBeatWaveData:(NSData *)waveData{
    NSData *pointData = [waveData subdataWithRange:NSMakeRange(sizeof(VTMFileHead), waveData.length - sizeof(VTMFileHead) - sizeof(VTMER2FileTail))];
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < pointData.length; i+= sizeof(VTMER1PointData)) {
        VTMER1PointData point;
        [pointData getBytes:&point range:NSMakeRange(i, sizeof(VTMER1PointData))];
//        [temp addObject:vbp];
    }
    return [temp copy];
}


#pragma mark -- config
#pragma mark --- ER1/VBeat

+ (VTMER1Config)parseER1Config:(NSData *)data{
    VTMER1Config config;
    [data getBytes:&config length:sizeof(VTMER1Config)];
    return config;
}

#pragma mark --- ER2/DuoEK

+ (VTMER2Config)parseER2Config:(NSData *)data{
    VTMER2Config config;
    [data getBytes:&config length:sizeof(VTMER2Config)];
    return config;
}


@end


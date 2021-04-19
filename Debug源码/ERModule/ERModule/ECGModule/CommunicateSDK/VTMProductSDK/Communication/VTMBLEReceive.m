//
//  VTMBLEReceive.m
//  VTMProductDemo
//
//  Created by viatom on 2020/10/29.
//

#import "VTMBLEReceive.h"
#import "VTMCalibrate.h"

@implementation VTMBLEReceive

+ (void)receiveData:(NSData *)data parseResult:(VTMBLEResponse)response{
    u_char *dataBuf = (u_char *)data.bytes;
    u_char head = dataBuf[0];
    if (head != VTMBLEHeaderDefault) {
        response(VTMBLEPkgTypeHeadError, VTMBLEPkgTypeHeadError, nil); // 包头错误
    }else{
        u_char cmd = dataBuf[1];
        if (dataBuf[data.length - 1] != [VTMCalibrate calCRC8:dataBuf bufSize:data.length - 1]) {
            response(cmd, VTMBLEPkgTypeCRCError, nil);
        }else{
            VTMBLEPkgType type = dataBuf[3];
            response(cmd, type, [data subdataWithRange:NSMakeRange(7, data.length-8)]);
        }
    }
}

+ (instancetype)modelWithReceiveData:(NSData *)data{
    VTMBLEReceive *receive = [[VTMBLEReceive alloc] init];
    u_char *dataBuf = (u_char *)data.bytes;
    u_char head = dataBuf[0];
    if (head != VTMBLEHeaderDefault) {
        receive.cmd = VTMBLEPkgTypeHeadError;
        receive.type = VTMBLEPkgTypeHeadError;
        receive.response = nil;
    }else{
        u_char cmd = dataBuf[1];
        if (dataBuf[data.length - 1] != [VTMCalibrate calCRC8:dataBuf bufSize:data.length - 1]) {
            receive.cmd = cmd;
            receive.type = VTMBLEPkgTypeCRCError;
            receive.response = nil;
        }else{
            VTMBLEPkgType type = dataBuf[3];
            receive.cmd = cmd;
            receive.type = type;
            receive.response = [data subdataWithRange:NSMakeRange(7, data.length-8)];
        }
    }
    return receive;
}

@end

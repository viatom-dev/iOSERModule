//
//  ERDeviceInfo.m
//  ERModule
//
//  Created by yangweichao on 2021/4/9.
//

#import "ERDeviceInfo.h"

@implementation ERDeviceInfo

- (void)saveOrUpdateDeviceInfo:(VTMDeviceInfo)info{
    self.hw_version = [NSString stringWithFormat:@"%c",info.hw_version];
    self.fw_version = [self uintToNSString:info.fw_version];
    self.bl_version = [self uintToNSString:info.bl_version];
    self.branch_code = [self ucharCArrayToNSString:info.branch_code withLen:sizeof(info.branch_code)];
    self.devce_type = [NSString stringWithFormat:@"%02d%02d",(info.device_type << 8) & 0xff,info.device_type];
    self.protocol_version = [NSString stringWithFormat:@"%d.%d",(info.protocol_version << 8) & 0xff,info.protocol_version];
    self.device_sn = [self ucharCArrayToNSString:info.sn.serial_num withLen:info.sn.len];
    [self saveOrUpdateByColumnName:@"device_sn" AndColumnValue:[NSString stringWithFormat:@"'%@'", self.device_sn]];
}



- (NSString *)uintToNSString:(u_int)x{
    u_char k0 = (x >> 16) & 0xff;
    u_char k1 = (x >> 8) & 0xff;
    u_char k2 = x;
    return [NSString stringWithFormat:@"%d.%d.%d",k0,k1,k2];
}

- (NSString *)ucharCArrayToNSString:(u_char *)cArray withLen:(int)len{
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        [str appendString:[NSString stringWithFormat:@"%c",cArray[i]]];
    }
    return [str copy];
}

- (NSString *)timeFromCTimeArray:(u_char *)time{
    int year = time[0] + (time[1] << 8);
    int month = time[2];
    int day = time[3];
    int hour = time[4];
    int min = time[5];
    int sec = time[6];
    return [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d",year,month,day,hour,min,sec];
}



@end

//
//  VTDevice.m
//  VTO2Lib
//
//  Created by viatom on 2020/6/23.
//  Copyright © 2020 viatom. All rights reserved.
//

#import "VTDevice.h"

@implementation VTDevice

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral adv:(NSDictionary *)advDic RSSI:(NSNumber *)RSSI{
    self = [super init];
    if (self) {
        self.RSSI = RSSI;
        self.advName = [advDic objectForKey:@"kCBAdvDataLocalName"];
        if (![self.advName isKindOfClass:[NSNull class]] &&
            ![self.advName isEqualToString:@""] &&
            self.advName != nil && 
            ![peripheral.name isEqualToString:self.advName]) {
            [peripheral setValue:self.advName forKey:@"name"];
        }
        self.rawPeripheral = peripheral;
        NSLog(@"发现设备：%@", self.rawPeripheral);
        if (![peripheral.name hasPrefix:@"ER1"]) {
            return nil;
        }
    }
    return self;
}

@end

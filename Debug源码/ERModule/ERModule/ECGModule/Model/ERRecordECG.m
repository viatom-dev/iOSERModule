//
//  ERRecordECG.m
//  ViHealth
//
//  Created by Viatom on 2019/7/22.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "ERRecordECG.h"
#import "ERFileManager.h"
#import "VTCustomText.h"
#import "VTERUser.h"
#import <objc/runtime.h>

@implementation ERRecordECG

- (instancetype)init{
    self = [super init];
    if (self) {
        VTERUser *user = [VTCustomText sharedInstance].user;
        uint count = 0;
        objc_property_t *properties = class_copyPropertyList([VTERUser class], &count);
        for (int i = 0; i < count; i ++) {
            objc_property_t property = properties[i];
            NSString *name = @(property_getName(property));
            [self setValue:[user valueForKey:name] forKey:name];
        }
        free(properties);
        
    }
    return self;
}


- (NSArray *)readShortFilePoints{
    NSString *fileName = self.fileUrl.lastPathComponent;
    NSString *fileFold = [self.fileUrl componentsSeparatedByString:@"/"].firstObject;
    NSData *orignalData = [ERFileManager readFile:fileName inDirectory:fileFold];
    NSString *str = [[NSString alloc] initWithData:orignalData encoding:NSUTF8StringEncoding];
    NSArray *points = [str componentsSeparatedByString:@","];
    return points;
}

- (NSDictionary *)dataDicFromData{
    NSString *receiveStr = [[NSString alloc]initWithData:self.aiResponse encoding:NSUTF8StringEncoding];
    NSData * datas = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableLeaves error:nil];
    return jsonDict;
}

- (void)setResponseData:(NSDictionary *)dict{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    self.aiResponse = data;
}

@end

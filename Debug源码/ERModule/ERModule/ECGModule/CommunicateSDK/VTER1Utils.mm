//
//  VTER1Utils.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import "VTER1Utils.h"

@implementation VTER1Utils

static VTER1Utils *utils = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [[self alloc] init];
    });
    return utils;
}




@end

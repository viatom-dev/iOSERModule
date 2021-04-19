//
//  VTStartUtils.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import "VTStartUtils.h"
#import "VTER1RealViewController.h"
#import "VTNavigationViewController.h"

@implementation VTStartUtils

+ (void)startWithTarget:(UIViewController *)superViewController{
    VTER1RealViewController *vc = [[VTER1RealViewController alloc] init];
    VTNavigationViewController *nav = [[VTNavigationViewController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [superViewController presentViewController:nav animated:YES completion:nil];
}



@end

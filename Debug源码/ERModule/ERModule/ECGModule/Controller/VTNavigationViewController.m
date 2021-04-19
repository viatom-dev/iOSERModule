//
//  VTNavigationViewController.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import "VTNavigationViewController.h"

@interface VTNavigationViewController ()

@end

@implementation VTNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
}


+ (void)initialize{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
        //设置导航栏背景颜色
    [navigationBar setBarTintColor:[UIColor blackColor]];
    [navigationBar setTintColor:[UIColor whiteColor]];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


- (BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}


@end

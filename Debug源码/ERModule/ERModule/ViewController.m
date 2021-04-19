//
//  ViewController.m
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#import "ViewController.h"
#import "VTStartUtils.h"
#import "VTCustomText.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *testBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.testBtn.center = self.view.center;
    [VTCustomText sharedInstance].receiveInterval = 1*60;
}


- (UIButton *)testBtn{
    if (!_testBtn) {
        _testBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        [_testBtn setTitle:@"Test" forState:UIControlStateNormal];
        [_testBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [_testBtn addTarget:self action:@selector(testPresent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_testBtn];
        
    }
    return _testBtn;
}

- (void)testPresent:(UIButton *)button{
    [VTStartUtils startWithTarget:self];
}

@end

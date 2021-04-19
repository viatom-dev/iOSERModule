//
//  VTScanDashboard.h
//  ERModule
//
//  Created by yangweichao on 2021/4/14.
//

#import <UIKit/UIKit.h>
#import "VTDevice.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VTScanDashboardDelegate <NSObject>

@optional
- (void)restartScan;

- (void)connectToDevice:(VTDevice *)device;

- (void)disconnectDevice:(VTDevice *)device;

@end

@interface VTScanDashboard : UIView<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<VTScanDashboardDelegate> delegate;

- (void)addConnectedDevice:(VTDevice *)device;

- (void)addScanningDevice:(VTDevice *)device;

@end

NS_ASSUME_NONNULL_END

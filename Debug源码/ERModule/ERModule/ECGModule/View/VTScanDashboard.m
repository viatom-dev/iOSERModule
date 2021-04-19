//
//  VTScanDashboard.m
//  ERModule
//
//  Created by yangweichao on 2021/4/14.
//

#import "VTScanDashboard.h"

@interface VTScanDashboard ()

@property (nonatomic, strong) NSMutableArray *connectedArray;
@property (nonatomic, strong) NSMutableArray *scanningArray;
@property (nonatomic, strong) NSMutableArray *scanningIDArray;

@end

@implementation VTScanDashboard

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
        self.frame = frame;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.separatorColor = [UIColor colorWithRed:84/255.0 green:84/255.0 blue:88/255.0 alpha:0.5];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        _refreshBtn.layer.cornerRadius = 15;
        _refreshBtn.layer.masksToBounds = YES;
        
    }
    return self;
}

- (NSMutableArray *)connectedArray{
    if (!_connectedArray) {
        _connectedArray = [NSMutableArray array];
    }
    return _connectedArray;
}

- (NSMutableArray *)scanningArray{
    if (!_scanningArray) {
        _scanningArray = [NSMutableArray array];
    }
    return _scanningArray;
}

- (NSMutableArray *)scanningIDArray{
    if (!_scanningIDArray) {
        _scanningIDArray = [NSMutableArray array];
    }
    return _scanningIDArray;
}

- (void)addConnectedDevice:(VTDevice *)device{
    [self.connectedArray addObject:device];
    [_tableView reloadData];
}

- (void)addScanningDevice:(VTDevice *)device{
    NSUUID *identifier = [device.rawPeripheral identifier];
    if ([_scanningIDArray containsObject:identifier]) {
        NSUInteger index = [_scanningIDArray indexOfObject:identifier];
        [_scanningArray replaceObjectAtIndex:index withObject:device];
    }else{
        [_scanningArray addObject:device];
        [_scanningIDArray addObject:identifier];
    }
    [_tableView reloadData];
}

- (IBAction)refreshList:(UIButton *)sender {
    [_connectedArray removeAllObjects];
    [_scanningArray removeAllObjects];
    [_scanningIDArray removeAllObjects];
    
    if (_delegate && [_delegate respondsToSelector:@selector(restartScan)]) {
        [_delegate restartScan];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.connectedArray.count;
    }else{
        return self.scanningArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"已连接的设备";
    }else{
        return @"其他设备";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:28/255.0 green:28/255.0 blue:30/255.0 alpha:1/1.0];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:245/255.0 alpha:0.6/1.0]];
    [header.textLabel setFont:[UIFont systemFontOfSize:14]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"scanIdenty";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:48/255.0 alpha:1/1.0];
    }
    if (indexPath.section == 0) {
        VTDevice *d = _connectedArray[indexPath.row];
        cell.textLabel.text = d.rawPeripheral.name;
        cell.detailTextLabel.text = @"已连接";
    }else{
        VTDevice *d = _scanningArray[indexPath.row];
        cell.textLabel.text = d.rawPeripheral.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", d.RSSI];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        VTDevice *d = _connectedArray[indexPath.row];
        [_connectedArray removeObject:d];
        [tableView reloadData];
        if (_delegate && [_delegate respondsToSelector:@selector(disconnectDevice:)]) {
            [_delegate disconnectDevice:d];
        }
    }else{
        VTDevice *d = _scanningArray[indexPath.row];
        if (_delegate && [_delegate respondsToSelector:@selector(connectToDevice:)]) {
            [_delegate connectToDevice:d];
        }
    }
}

@end

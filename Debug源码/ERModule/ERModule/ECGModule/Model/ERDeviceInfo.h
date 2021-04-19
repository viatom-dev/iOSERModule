//
//  ERDeviceInfo.h
//  ERModule
//
//  Created by yangweichao on 2021/4/9.
//

#import "JKDBModel.h"
#import "VTMBLEStruct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ERDeviceInfo : JKDBModel

@property (nonatomic, copy) NSString *hw_version;
@property (nonatomic, copy) NSString *fw_version;
@property (nonatomic, copy) NSString *bl_version;
@property (nonatomic, copy) NSString *branch_code;
@property (nonatomic, copy) NSString *devce_type;
@property (nonatomic, copy) NSString *protocol_version;
@property (nonatomic, copy) NSString *device_sn;

- (void)saveOrUpdateDeviceInfo:(VTMDeviceInfo)info;

@end

NS_ASSUME_NONNULL_END

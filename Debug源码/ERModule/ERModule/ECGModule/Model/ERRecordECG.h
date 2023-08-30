//
//  ERRecordECG.h
//  ViHealth
//
//  Created by Viatom on 2019/7/22.
//  Copyright © 2019年 Viatom. All rights reserved.
//

#import "JKDBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ERRecordECG : JKDBModel

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, assign) BOOL manaul; // 手动
@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *aiReportUrl;


/// 昵称
@property (nonatomic,copy) NSString *nickName;

/// 性别 1：男；2：女
@property (nonatomic,copy) NSString *gender;

/// 出生年月日 yyyy-MM-dd
@property (nonatomic,copy) NSString *dateBirth;

/// 手机号码
@property (nonatomic,copy) NSString *phone;

/// 身份证号码
@property (nonatomic,copy) NSString *idcard;

@property (nonatomic,copy)NSString *height;//身高
@property (nonatomic,copy)NSString *weight;//体重

@property (nonatomic, copy) NSString *analysis_id;
@property (nonatomic, assign) NSUInteger status;

@property (nonatomic, copy) NSString *hr;
@property (nonatomic, copy) NSString *isShowAiResult;
@property (nonatomic, copy) NSString *shortRangeTime;
@property (nonatomic, copy) NSString *sendTime;
@property (nonatomic, copy) NSString *levelCode;
@property (nonatomic, copy) NSString *aiResult;
@property (nonatomic, copy) NSString *aiDiagnosis;


/// 记录返回数据版本信息， 旧接口已生成数据为0， 新接口生成数据置为1
@property (nonatomic, assign) NSUInteger responseVer;

@property (nonatomic, copy) NSData *aiResponse; // 存储ai分析 data 部分数据

- (void)setResponseData:(NSDictionary *)dict;

- (NSArray *)readShortFilePoints;
- (NSDictionary *)dataDicFromData;


@end

NS_ASSUME_NONNULL_END

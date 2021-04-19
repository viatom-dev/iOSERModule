//
//  ECGReportInfoData.h
//  Checkme Mobile
//
//  Created by 李乾 on 15/1/1.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VTERUser, ERRecordECG;
@interface ECGReportInfoData : UIView

@property (nonatomic, strong) VTERUser *member;
@property (nonatomic, strong) ERRecordECG *ecgRecord;


@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *nameValueLab;

@property (weak, nonatomic) IBOutlet UILabel *genderLab;
@property (weak, nonatomic) IBOutlet UILabel *genderValueLab;

@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *birthLab;
@property (weak, nonatomic) IBOutlet UILabel *birthValueLab;

@property (strong, nonatomic) IBOutlet UIImageView *mesureImage;


@property (weak, nonatomic) IBOutlet UILabel *duringLab;
@property (weak, nonatomic) IBOutlet UILabel *duringValueLab;

@property (weak, nonatomic) IBOutlet UILabel *startLab;
@property (weak, nonatomic) IBOutlet UILabel *startValueLab;

@property (weak, nonatomic) IBOutlet UILabel *endLab;
@property (weak, nonatomic) IBOutlet UILabel *endValueLab;

@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UILabel *dateValueLab;

@property (weak, nonatomic) IBOutlet UILabel *hrLab;
@property (weak, nonatomic) IBOutlet UILabel *hrValueLab;

@property (weak, nonatomic) IBOutlet UILabel *symptomLab;
@property (weak, nonatomic) IBOutlet UILabel *symptomValueLab;

@end

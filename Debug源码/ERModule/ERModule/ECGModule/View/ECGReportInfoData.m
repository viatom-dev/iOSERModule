//
//  ECGReportInfoData.m
//  Checkme Mobile
//
//  Created by 李乾 on 15/1/1.
//  Copyright (c) 2015年 VIATOM. All rights reserved.
//

#import "ECGReportInfoData.h"
#import "VTMarco.h"
#import "VTERUser.h"
#import "ERRecordECG.h"

@implementation ECGReportInfoData

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    self.bounds = CGRectMake(0, 0, wave_width, self.frame.size.height);
    
    _nameLab.text = @"姓名:";
    _genderLab.text = @"性别:";
    _heightLabel.text = @"身高:";
    _weightLabel.text = @"体重:";
    _birthLab.text = @"出生日期:";
    
    _duringLab.text = @"AI分析波形时长:";
    _startLab.text = @"开始时间:";
    _endLab.text = @"结束时间:";
    _dateLab.text = @"AI分析日期:";
    _hrLab.text = @"心率:";
    _symptomLab.text = @"症状:";
    
    [_nameLab sizeToFit]; [_genderLab sizeToFit];
    
    _duringValueLab.text = @"30秒";
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;
}

//- (void)drawRect:(CGRect)rect {
//    [self drawRectangle];
//}

//画矩形框
- (void)drawRectangle {
    CGPoint point1 = CGPointMake(1, 1);
    CGPoint point2 = CGPointMake(wave_width-2, point1.y);
    CGPoint point3 = CGPointMake(point2.x, self.bounds.size.height-2);
    CGPoint point4 = CGPointMake(point1.x, point3.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point1];
    
    [[UIColor blackColor] setStroke];
    path.lineWidth = thickLineW;
    [path stroke];
}

- (void)setEcgRecord:(ERRecordECG *)ecgRecord{
    _ecgRecord = ecgRecord;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = (NSDate *)[formatter dateFromString:ecgRecord.startTime];
    NSTimeInterval endInterval = [date timeIntervalSince1970] + 30;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _startValueLab.text = [formatter stringFromDate:date];
    _endValueLab.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:endInterval]];
    _dateValueLab.text = ecgRecord.shortRangeTime;
    _hrValueLab.text = [ecgRecord.hr stringByAppendingString:@"bpm"];
    _symptomValueLab.text = @"";
    
    _nameValueLab.text = ecgRecord.nickName;
    _genderValueLab.text = ecgRecord.gender.length > 0 ? (ecgRecord.gender.integerValue == 1 ? @"男" : @"女") : nil;
    _heightValueLabel.text= ecgRecord.height.length > 0 ? [NSString stringWithFormat:@"%@cm", ecgRecord.height] : nil;
    _weightValueLabel.text= ecgRecord.weight.length > 0 ? [NSString stringWithFormat:@"%@kg", ecgRecord.weight] : nil;
    _birthValueLab.text = ecgRecord.dateBirth;
}


@end

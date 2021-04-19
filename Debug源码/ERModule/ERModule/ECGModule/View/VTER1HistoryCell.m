//
//  VTER1HistoryCell.m
//  ERModule
//
//  Created by yangweichao on 2021/4/12.
//

#import "VTER1HistoryCell.h"

@implementation VTER1HistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _hrLab.text = @"平均心率";
    _hrUnitLab.text = @"bpm";
    _hrValLab.text = @"--";
    _aiResultLab.text = @"";
    self.backgroundColor = [UIColor blackColor];
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

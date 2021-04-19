//
//  VTER1HistoryCell.h
//  ERModule
//
//  Created by yangweichao on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VTER1HistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UILabel *fromLab;
@property (weak, nonatomic) IBOutlet UILabel *hrLab;
@property (weak, nonatomic) IBOutlet UILabel *aiResultLab;
@property (weak, nonatomic) IBOutlet UILabel *hrValLab;
@property (weak, nonatomic) IBOutlet UILabel *hrUnitLab;

@end

NS_ASSUME_NONNULL_END

//
//  ERECGReport.m
//  iwown
//
//  Created by viatom on 2020/5/6.
//  Copyright © 2020 LP. All rights reserved.
//

#import "ERECGReport.h"
#import "VTMarco.h"
#import <Masonry.h>
#import "UIColor+Extensions.h"

@interface ERECGReport ()

@property (nonatomic, strong) UIImageView *headerImage;

@end

@implementation ERECGReport {
    NSDateFormatter *_dateFormatter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configrationUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)configrationUI {
    // 添加logo

//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"report_Logo"]];
//    self.headerImage = imageView;
//    [self addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(30);
//        make.left.equalTo(self).inset(viapadding);
//        make.top.equalTo(self).inset(viapadding*0.6);
//    }];
//
//    UILabel *titleLabel = [[UILabel alloc] init];
//    titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    titleLabel.text = @"乐普医疗心脏数据中心";
//    titleLabel.textColor = [UIColor colorWithHex:@"#0075c1"];
//    [self addSubview:titleLabel];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(imageView);
//        make.left.equalTo(imageView.mas_right).offset(4);
//    }];
//
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    self.contentView = contentView;
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).inset(viapadding-1);
        make.left.right.bottom.equalTo(self).inset(viapadding-1);//viapadding = 22.5
    }];
    
    [self layoutIfNeeded];
}

@end

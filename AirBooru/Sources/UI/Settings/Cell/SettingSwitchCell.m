//
// Created by qii on 7/11/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "SettingSwitchCell.h"
#import "ThemeHelper.h"
#import "View+MASAdditions.h"

@interface SettingSwitchCell ()
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UISwitch *switchControl;
@property(nonatomic, strong) UIView *topBorderLineView;
@property(nonatomic, strong) UIView *bottomBorderLineView;
@end

@implementation SettingSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_greaterThanOrEqualTo(@180);
            make.height.mas_equalTo(@50);
            make.left.mas_equalTo(self.contentView.mas_left).offset(15);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];

        self.switchControl = [UISwitch new];
        [self.contentView addSubview:self.switchControl];
        [self.switchControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_greaterThanOrEqualTo(@1);
            make.height.mas_greaterThanOrEqualTo(@1);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];

        self.topBorderLineView = [UIView new];
        self.topBorderLineView.backgroundColor = [ThemeHelper settingCellLineColor];
        [self.contentView addSubview:self.topBorderLineView];
        [self.topBorderLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.contentView).offset(80);
            make.height.mas_equalTo(@0.5);
            make.top.equalTo(self.contentView.mas_top);
        }];

        self.bottomBorderLineView = [UIView new];
        self.bottomBorderLineView.backgroundColor = [ThemeHelper settingCellLineColor];
        [self.contentView addSubview:self.bottomBorderLineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isBottom) {
        self.bottomBorderLineView.frame = (CGRect) {0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5};
    } else {
        self.bottomBorderLineView.frame = (CGRect) {15, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5};
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIColor *color = [UIColor whiteColor];
    if (selected) {
        color = [ThemeHelper settingCellHighLightedColor];
        self.backgroundColor = color;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = color;
        }                completion:^(BOOL finished) {
            [self setNeedsLayout];
        }];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    UIColor *color = [UIColor whiteColor];
    if (highlighted) {
        color = [ThemeHelper settingCellHighLightedColor];
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = color;
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = _title;
}

- (void)setTop:(BOOL)top {
    _top = top;
    self.topBorderLineView.hidden = !_top;
}

@end
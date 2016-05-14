//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "TagCell.h"
#import "View+MASAdditions.h"
#import "Tag.h"

@interface TagCell ()
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *count;
@end

@implementation TagCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        self.name = [UILabel new];
        [self.contentView addSubview:self.name];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.contentView.mas_left).offset(20);
            make.width.equalTo(self.contentView.mas_width);
            make.height.equalTo(@50);
        }];
//        self.name.backgroundColor = [UIColor redColor];


        self.count = [UILabel new];
        [self.contentView addSubview:self.count];
        [self.count mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_greaterThanOrEqualTo(@50);
            make.height.mas_equalTo(@50);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
//        self.count.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)setPostTag:(Tag *)postTag {
    _postTag = postTag;
    self.name.text = self.postTag.name;
    self.count.text = [NSString stringWithFormat:@"%llu posts", self.postTag.count];
}

@end

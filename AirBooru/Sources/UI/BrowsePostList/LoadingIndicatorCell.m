//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LoadingIndicatorCell.h"

@interface LoadingIndicatorCell ()
@property(strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation LoadingIndicatorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.indicatorView startAnimating];
}

@end
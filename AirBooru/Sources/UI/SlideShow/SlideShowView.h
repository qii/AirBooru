//
// Created by qii on 6/3/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef void (^SlideShowAnimationCompletionBlock)(int exitIndex);

@interface SlideShowView : UIView
@property(copy, nonatomic) SlideShowAnimationCompletionBlock completionBlock;
@property(assign, nonatomic) int exitIndex;

@property(strong, nonatomic) UIImage *exitImage;
@property(strong, nonatomic) UIImage *enterImage;

- (void)start;
@end
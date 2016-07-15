//
// Created by qii on 2/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef void (^ZoomScrollSingleTapBlock)();

@interface ZoomScrollView : UIScrollView
@property(strong, nonatomic) UIImage *image;
@property(copy, nonatomic) ZoomScrollSingleTapBlock singleTapBlock;
@end


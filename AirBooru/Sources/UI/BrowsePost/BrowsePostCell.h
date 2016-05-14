//
// Created by qii on 5/2/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "ZoomScrollView.h"

@class Post;

@interface BrowsePostCell : UIView
@property(strong, nonatomic) Post *post;
@property(copy, nonatomic) ZoomScrollSingleTapBlock singleTapBlock;

- (void)beginDownloadImage;

- (void)destroyFromViewPager;
@end
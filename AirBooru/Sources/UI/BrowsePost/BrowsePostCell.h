//
// Created by qii on 5/2/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "GesturePictureView.h"

@class Post;

@interface BrowsePostCell : UIView
@property(strong, nonatomic) Post *post;
@property(copy, nonatomic) SingleTapBlock singleTapBlock;

- (void)beginDownloadImage;

- (void)destroyFromViewPager;
@end
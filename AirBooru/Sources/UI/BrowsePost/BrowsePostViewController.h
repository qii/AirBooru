//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PostList;

@interface BrowsePostViewController : UIViewController
+ (instancetype)viewControllerWithPostList:(PostList *)postList index:(int)index;
@end
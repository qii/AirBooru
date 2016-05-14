//
// Created by qii on 7/7/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "PostListViewController.h"

@class Tag;
@class ImageBoard2;


@interface PostByTagViewController : PostListViewController
@property(nonatomic, strong) Tag *postTag;
@end
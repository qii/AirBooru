//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PostListViewController.h"

@class ImageBoard2;


@interface TagPostListViewController : PostListViewController
@property(nonatomic, strong) NSString *tagName;
@end
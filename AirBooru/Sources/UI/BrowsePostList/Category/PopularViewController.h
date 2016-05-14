//
// Created by qii on 7/9/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostListViewController.h"

@class ImageBoard2;

@interface PopularViewController : PostListViewController
@property(nonatomic, weak) ImageBoard2 *imageBoard;
@property(nonatomic, strong) NSString *period;
@end
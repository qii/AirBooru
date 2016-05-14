//
// Created by qii on 7/9/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostListApi.h"

@class ImageBoard2;


@interface PopularListApi : NSObject
@property(copy, nonatomic) PostListApiBlock block;
@property(assign, readonly, nonatomic) int page;
@property(nonatomic, strong) ImageBoard2 *imageBoard;
@property (nonatomic, strong) NSString *period;

- (void)loadLatestData;

@end
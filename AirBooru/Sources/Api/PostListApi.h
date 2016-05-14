//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PostList;
@class ImageBoard2;
@class Tag;

typedef void (^PostListApiBlock)(PostList *request, BOOL finished, NSError *error);

@interface PostListApi : NSObject
@property(nonatomic, copy) PostListApiBlock block;
@property(nonatomic, assign, readonly) int page;
@property(nonatomic, strong) ImageBoard2 *imageBoard;
@property(nonatomic, strong) Tag *postTag;

- (BOOL)loadLatestData;

- (BOOL)loadPreviousData;

@end
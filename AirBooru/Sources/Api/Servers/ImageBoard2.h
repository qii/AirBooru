//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PostList;
@class TagList;


@interface ImageBoard2 : NSObject
- (PostList *)queryPostList:(int)page limit:(int)limit tags:(NSArray *)tags error:(NSError **)outError;

- (TagList *)queryTagList:(int)page limit:(int)limit name:(NSString *)name error:(NSError **)outError;

- (PostList *)queryPopularPostList:(int)page limit:(int)limit period:(NSString *)period error:(NSError **)outError;
@end
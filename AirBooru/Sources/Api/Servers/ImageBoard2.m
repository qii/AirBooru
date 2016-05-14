//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ImageBoard2.h"
#import "PostList.h"
#import "TagList.h"


@implementation ImageBoard2

- (PostList *)queryPostList:(int)page limit:(int)limit tags:(NSArray *)tags error:(NSError **)outError {
    NSLog(@"Subclass must implement queryPostList");
    return nil;
}

- (TagList *)queryTagList:(int)page limit:(int)limit name:(NSString *)name error:(NSError **)outError {
    NSLog(@"Subclass must implement queryTagList");
    return nil;
}

- (PostList *)queryPopularPostList:(int)page limit:(int)limit period:(NSString *)period error:(NSError **)outError {
    NSLog(@"Subclass must implement queryPopularPostList");
    return nil;
}

@end
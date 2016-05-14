//
// Created by qii on 7/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSQLiteDatabase.h"

@class Post;

@interface HomeDB : OpenSQLiteDatabase

- (void)open:(NSString *)serverIdentifyId;

- (void)addPosts:(NSArray *)posts;

- (NSArray *)query;

@end
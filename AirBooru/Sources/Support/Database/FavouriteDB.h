//
// Created by qii on 7/10/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSQLiteDatabase.h"

@class Post;


@interface FavouriteDB : OpenSQLiteDatabase

+ (instancetype)sharedInstance;

- (void)addPost:(Post *)post;

- (NSArray *)query;

- (BOOL)isFavourite:(long long)postId;

- (void)deletePost:(long long)postId;

@end
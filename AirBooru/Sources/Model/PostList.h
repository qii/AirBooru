//
// Created by qii on 4/24/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;


@interface PostList : NSObject
@property(strong, nonatomic) NSArray *posts;
@property(assign, readonly, nonatomic) int count;

+ (instancetype)parseJson:(NSString *)json isUserConfig:(BOOL)isUserConfig;

+ (instancetype)parseJsonGelbooru:(NSString *)url json:(NSString *)json isUserConfig:(BOOL)isUserConfig;

- (Post *)objectAtIndexedSubscript:(NSUInteger)index;

- (Post *)getPostAt:(int)index;

- (void)addPosts:(NSArray *)posts;
@end
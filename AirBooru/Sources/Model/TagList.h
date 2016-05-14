//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag;


@interface TagList : NSObject
@property(strong, nonatomic) NSArray *tags;

+ (instancetype)parseJson:(NSString *)json isUserConfig:(BOOL)isUserConfig;

+ (instancetype)parseJsonGelbooru:(NSString *)url json:(NSString *)json;

- (Tag *)getTagAt:(int)index;

- (void)addTags:(NSArray *)tags;
@end
//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tag : NSObject
@property(nonatomic, assign) long long tagId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) long long count;
@property(nonatomic, assign) int type;
@property(nonatomic, assign) BOOL ambiguous;

+ (instancetype)parseJson:(NSDictionary *)json;

- (BOOL)isStoreSafe;
@end
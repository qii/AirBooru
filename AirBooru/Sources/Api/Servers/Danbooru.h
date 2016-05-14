//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBoard2.h"

@interface Danbooru : ImageBoard2
@property(nonatomic, strong) NSString *url;
@property(nonatomic, readonly, strong) NSString *name;
@property(nonatomic, assign, getter= isUserConfig) BOOL userConfig;

+ (instancetype)danbooruWithURL:(NSString *)url isUserConfig:(BOOL)isUserConfig;

- (NSString *)identifyId;

@end
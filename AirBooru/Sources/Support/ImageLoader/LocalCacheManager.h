//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalCacheDB;


@interface LocalCacheManager : NSObject
+ (instancetype)sharedInstance;

- (LocalCacheDB *)getCacheDB:(NSString *)serverName;
@end
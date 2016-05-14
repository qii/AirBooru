//
// Created by qii on 7/28/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StoreSafe : NSObject
+ (NSArray *)dangerousTags;

+ (NSArray *)dangerousIds;

+ (NSArray *)safeTags;
@end
//
// Created by qii on 7/13/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "NSDictionary+NotNullKey.h"


@implementation NSDictionary (NotNullKey)
- (id)objectForSafeKey:(id)key {
    id object = self[key];
    if ([object isEqual:[NSNull null]])
        return nil;
    return object;
}
@end
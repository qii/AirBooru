//
// Created by qii on 5/3/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "UIView+StringTagAdditions.h"
#import <objc/runtime.h>

@implementation UIView (StringTagAdditions)
static NSString *kStringTagKey = @"StringTagKey";

- (NSString *)abu_stringTag {
    return objc_getAssociatedObject(self, kStringTagKey.UTF8String);
}

- (void)setAbu_stringTag:(NSString *)abu_stringTag {
    objc_setAssociatedObject(self, kStringTagKey.UTF8String, abu_stringTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
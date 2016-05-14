//
// Created by qii on 5/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+ObjectTagAdditions.h"
#import "WeakRef.h"


@implementation UIView (ObjectTagAdditions)
static NSString *kObjectTagKey = @"objectTagKey";

- (NSObject *)objectTag {
    WeakRef *ref = objc_getAssociatedObject(self, kObjectTagKey.UTF8String);
    return ref.object;
}

- (void)setObjectTag:(NSObject *)objectTag {
    objc_setAssociatedObject(self, kObjectTagKey.UTF8String, [[WeakRef alloc] initWithObject:objectTag], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
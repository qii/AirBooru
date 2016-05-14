//
// Created by qii on 4/10/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import "WeakRef.h"


@implementation WeakRef

- (id)initWithObject:(id)object {
    self = [super init];
    _object = object;
    return self;
}

@end
//
// Created by qii on 4/10/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import <Foundation/Foundation.h>

//http://stackoverflow.com/questions/4692161/non-retaining-array-for-delegates/4692229#4692229

@interface WeakRef : NSObject

@property(weak, nonatomic, readonly) id object;

- (id)initWithObject:(id)object;

@end
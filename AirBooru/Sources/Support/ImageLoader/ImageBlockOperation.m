//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ImageBlockOperation.h"

@interface ImageBlockOperation ()
@property(strong, nonatomic) NSMutableArray *optionArray;
@end

@implementation ImageBlockOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.optionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addOption:(ImageLoaderOption *)option {
    [self.optionArray addObject:option];
}

- (void)addOptions:(NSArray *)options {
    [self.optionArray addObjectsFromArray:options];
}

- (NSArray *)allOptions {
    return [NSArray arrayWithArray:self.optionArray];
}

@end
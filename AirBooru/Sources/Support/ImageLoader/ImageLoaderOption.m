//
// Created by qii on 5/2/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ImageLoaderOption.h"

@interface ImageLoaderOption ()

@end

@implementation ImageLoaderOption

- (instancetype)initWithSize:(CGSize)size successBlock:(ABUImageLoaderSuccessBlock)successBlock percentBlock:(ABUImageLoaderPercentBlock)percentBlock failureBlock:(ABUImageLoaderFailureBlock)failureBlock {
    self = [super init];
    self.size = size;
    self.successBlock = successBlock;
    self.percentBlock = percentBlock;
    self.failureBlock = failureBlock;
    return self;
}

@end
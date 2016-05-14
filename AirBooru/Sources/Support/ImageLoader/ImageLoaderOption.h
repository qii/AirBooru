//
// Created by qii on 5/2/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageLoader.h"


@interface ImageLoaderOption : NSObject
@property(assign, nonatomic) CGSize size;
@property(copy, nonatomic) ABUImageLoaderSuccessBlock successBlock;
@property(copy, nonatomic) ABUImageLoaderPercentBlock percentBlock;
@property(copy, nonatomic) ABUImageLoaderFailureBlock failureBlock;

- (instancetype)initWithSize:(CGSize)size
                successBlock:(ABUImageLoaderSuccessBlock)successBlock
                percentBlock:(ABUImageLoaderPercentBlock)percentBlock
                failureBlock:(ABUImageLoaderFailureBlock)failureBlock;
@end
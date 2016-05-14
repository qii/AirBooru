//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBlockOperation.h"

typedef void (^LocalOperationCompletionBlock)(UIImage *image);

@interface LocalOperation : ImageBlockOperation
@property(copy, nonatomic) NSString *localCacheFile;
@property(copy, nonatomic) LocalOperationCompletionBlock resultBlock;

+ (instancetype)operationWithPath:(NSString *)localCacheFile;
@end
//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBlockOperation.h"

typedef void (^NetworkOperationCompletionBlock)(BOOL downloadSuccess, NSString *cacheFile);

@interface NetworkOperation : ImageBlockOperation
@property(copy, nonatomic) NetworkOperationCompletionBlock resultBlock;

+ (instancetype)operationWithUrl:(NSString *)url;
@end
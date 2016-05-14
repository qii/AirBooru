//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBlockOperation.h"

typedef void (^LocalOrNetworkOperationCompletionBlock)(BOOL canReadCache, NSString *cacheFile);

@interface LocalOrNetworkOperation : ImageBlockOperation
@property(copy, nonatomic) LocalOrNetworkOperationCompletionBlock resultBlock;

+ (instancetype)operationWithUrl:(NSString *)url;
@end
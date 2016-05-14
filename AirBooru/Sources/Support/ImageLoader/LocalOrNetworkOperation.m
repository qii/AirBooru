//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LocalOrNetworkOperation.h"
#import "LocalCacheManager.h"
#import "LocalCacheDB.h"


@implementation LocalOrNetworkOperation

+ (instancetype)operationWithUrl:(NSString *)url {
    LocalOrNetworkOperation *operation = [[LocalOrNetworkOperation alloc] init];
    operation.url = url;
    return operation;
}

- (void)main {
    NSString *localCacheFile = [self readFromLocalCacheDBLog:self.url];
    BOOL canRead = localCacheFile != nil && [self canRead:localCacheFile];
    if (self.resultBlock != nil) {
        self.resultBlock(canRead, localCacheFile);
    }
}

- (NSString *)readFromLocalCacheDBLog:(NSString *)url {
    LocalCacheDB *db = [[LocalCacheManager sharedInstance] getCacheDB:@"yande"];
    return [db queryCacheFile:url];
}

//todo check is readable
- (BOOL)canRead:(NSString *)path {
//    return NO;
    return YES;
}

@end
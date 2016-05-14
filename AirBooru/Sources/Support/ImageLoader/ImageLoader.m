//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ImageLoader.h"
#import "ImageBlockOperation.h"
#import "LocalOrNetworkOperation.h"
#import "NetworkOperation.h"
#import "LocalOperation.h"
#import "AutoPurgeCache.h"
#import "ImageLoaderOption.h"
#import "ImageHelper.h"

///todo cgsize ImageLoader different cgsize use different localoperation
@interface ImageLoader ()
@property(strong, nonatomic) NSOperationQueue *localOrNetworkTasksQueue;    //read local cache or download from network
@property(strong, nonatomic) NSOperationQueue *localTasksQueue;
@property(strong, nonatomic) NSOperationQueue *networkTasksQueue;

@property(strong, nonatomic) NSMutableDictionary *localOrNetworkOperationsDictionary;
@property(strong, nonatomic) NSMutableDictionary *localOperationsDictionary;
@property(strong, nonatomic) NSMutableDictionary *networkOperationsDictionary;

@property(strong, nonatomic) AutoPurgeCache *memCache;
@end

@implementation ImageLoader

+ (instancetype)sharedInstance {
    static ImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.localOrNetworkOperationsDictionary = [[NSMutableDictionary alloc] init];
        self.localOperationsDictionary = [[NSMutableDictionary alloc] init];
        self.networkOperationsDictionary = [[NSMutableDictionary alloc] init];

        self.localOrNetworkTasksQueue = [[NSOperationQueue alloc] init];
        self.localOrNetworkTasksQueue.maxConcurrentOperationCount = 1;
        self.localTasksQueue = [[NSOperationQueue alloc] init];
        self.localTasksQueue.maxConcurrentOperationCount = 1;
        self.networkTasksQueue = [[NSOperationQueue alloc] init];
        self.networkTasksQueue.maxConcurrentOperationCount = 4;

        self.memCache = [[AutoPurgeCache alloc] init];
        self.memCache.totalCostLimit = (NSUInteger) 140 * 1024 * 1024; //40mb cache
    }
    return self;
}

- (void)loadImage:(NSString *)url option:(ImageLoaderOption *)option {
    UIImage *memCacheImage = [self.memCache objectForKey:url];
    if (memCacheImage != nil) {
        option.successBlock(url, memCacheImage);
        return;
    }

    ImageBlockOperation *operation = self.localOrNetworkOperationsDictionary[url];
    if (operation == nil) {
        LocalOrNetworkOperation *localOrNetworkOperation = [LocalOrNetworkOperation operationWithUrl:url];
        [localOrNetworkOperation addOption:option];
        __weak LocalOrNetworkOperation *weakOperation = localOrNetworkOperation;
        localOrNetworkOperation.resultBlock = ^void(BOOL canReadCache, NSString *cacheFile) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSArray *allOptions = weakOperation.allOptions;
                if (!canReadCache) {
                    [self downloadFromNetwork:url options:allOptions];
                } else {
                    [self readFromLocalCache:cacheFile url:url options:allOptions];
                }
                if (weakOperation == self.localOrNetworkOperationsDictionary[url]) {
                    [self.localOrNetworkOperationsDictionary removeObjectForKey:url];
                }
            }];
        };

        operation = localOrNetworkOperation;
        self.localOrNetworkOperationsDictionary[url] = operation;
        [self.localOrNetworkTasksQueue addOperation:operation];
    } else {
        [operation addOption:option];
    }
}

- (void)cancelLoadImage:(NSString *)url {
//    NSLog(@"ImageLoader cancelLoadImage");
    ImageBlockOperation *operation = self.localOperationsDictionary[url];
    if (operation != nil && !operation.isExecuting) {
        [operation cancel];
        [self.localOperationsDictionary removeObjectForKey:url];
    }
    operation = self.networkOperationsDictionary[url];
    if (operation != nil && !operation.isExecuting) {
        [operation cancel];
        [self.networkOperationsDictionary removeObjectForKey:url];
    }
    operation = self.localOperationsDictionary[url];
    if (operation != nil && !operation.isExecuting) {
        [operation cancel];
        [self.localOperationsDictionary removeObjectForKey:url];
    }
}

- (void)readFromLocalCache:(NSString *)path url:(NSString *)url options:(NSArray *)options {
    ImageBlockOperation *operation = self.localOperationsDictionary[url];
    if (operation == nil) {
        LocalOperation *blockOperation = [LocalOperation operationWithPath:path];
        [blockOperation addOptions:options];
        __weak LocalOperation *weakOperation = blockOperation;
        blockOperation.resultBlock = ^void(UIImage *image) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSArray *allOptions = weakOperation.allOptions;
                if (image != nil) {
                    [self.memCache setObject:image forKey:url cost:[ImageHelper calcImageMemCacheCost:image]];
                    for (ImageLoaderOption *option in allOptions) {
                        option.successBlock(url, image);
                    }
                } else {
                    for (ImageLoaderOption *option in allOptions) {
                        option.failureBlock(url, nil);
                    }
                }
                if (weakOperation == self.localOperationsDictionary[url]) {
                    [self.localOperationsDictionary removeObjectForKey:url];
                }
            }];
        };

        operation = blockOperation;
        self.localOperationsDictionary[url] = operation;
        [self.localTasksQueue addOperation:operation];
    } else {
        [operation addOptions:options];
    }
}

- (void)downloadFromNetwork:(NSString *)url options:(NSArray *)options {
    ImageBlockOperation *operation = self.networkOperationsDictionary[url];
    if (operation == nil) {
        NetworkOperation *networkOperation = [NetworkOperation operationWithUrl:url];
        [networkOperation addOptions:options];
        __weak NetworkOperation *weakOperation = networkOperation;
        networkOperation.resultBlock = ^void(BOOL downloadSuccess, NSString *cacheFile) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSArray *allOptions = weakOperation.allOptions;
                if (downloadSuccess) {
                    [self readFromLocalCache:cacheFile url:url options:allOptions];
                } else {
                    for (ImageLoaderOption *option in allOptions) {
                        option.failureBlock(url, nil);
                    }
                }
                if (weakOperation == self.networkOperationsDictionary[url]) {
                    [self.networkOperationsDictionary removeObjectForKey:url];
                }
            }];
        };

        operation = networkOperation;
        self.networkOperationsDictionary[url] = operation;
        [self.networkTasksQueue addOperation:operation];
    } else {
        [operation addOptions:options];
    }
}

- (void)queryCacheFile:(NSString *)url block:(ABUImageLoaderQueryCacheFileBlock)block {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    LocalOrNetworkOperation *localOrNetworkOperation = [LocalOrNetworkOperation operationWithUrl:url];
    localOrNetworkOperation.resultBlock = ^void(BOOL canReadCache, NSString *cacheFile) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (canReadCache) {
                block(url, cacheFile, nil);
            } else {
                ImageLoaderOption *option = [[ImageLoaderOption alloc] initWithSize:CGSizeMake(300, 300)
                                                                       successBlock:^(NSString *url, UIImage *image) {
                                                                           [self queryCacheFile:url block:block];
                                                                       } percentBlock:^(NSString *url, float percent) {

                        }                                              failureBlock:^(NSString *url, NSError *error) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                block(url, nil, nil);
                            }];
                        }];
                [self loadImage:url option:option];
            }

        }];
    };
    [queue addOperation:localOrNetworkOperation];
}

@end
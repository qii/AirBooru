//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PostListApi.h"
#import "PostList.h"
#import "UIHelper.h"
#import "Yandere.h"
#import "Tag.h"
#import "HomeDB.h"

static int const page_limit = 60;

@interface PostListApi ()
@property(strong, nonatomic) NSOperationQueue *queue;
@property(weak, nonatomic) NSOperation *currentLoadLatestOperation;
@property(weak, nonatomic) NSOperation *currentLoadPreviousOperation;
@property(assign, nonatomic) BOOL isLoadingLatest;
@property(assign, nonatomic) BOOL isLoadingPrevious;
@property(assign, nonatomic) CFAbsoluteTime previousRequestTime;
@property(strong, nonatomic) PostList *list;

@property(nonatomic, assign) BOOL isCachedLoaded;
@property(nonatomic, strong) HomeDB *homeDB;
@end

@implementation PostListApi

- (instancetype)init {
    self = [super init];
    if (self) {
        self.list = [[PostList alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 2;
        self.isLoadingLatest = NO;
        self.isLoadingPrevious = NO;
        self.isCachedLoaded = NO;
        _page = -1;
    }
    return self;
}

- (void)setImageBoard:(ImageBoard2 *)imageBoard {
    if (![_imageBoard isEqual:imageBoard]) {
        _isCachedLoaded = NO;
        _homeDB = nil;
        _imageBoard = imageBoard;
        _page = 0;
        if (self.currentLoadLatestOperation != nil) {
            [self.currentLoadLatestOperation cancel];
        }
        if (self.currentLoadPreviousOperation != nil) {
            [self.currentLoadPreviousOperation cancel];
        }
        self.isLoadingLatest = NO;
        self.isLoadingPrevious = NO;
    }
}

- (BOOL)loadLatestData {
    if (self.isLoadingPrevious) {
        return NO;
    }
    if (self.isLoadingLatest) {
        return YES;
    }

    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    if (time - self.previousRequestTime < 1) {
        return false;
    }
    self.previousRequestTime = time;

    self.isLoadingLatest = YES;

    [UIHelper UIShowNetworkIndicator:YES];
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak typeof(operation) weakOperation = operation;
    [operation addExecutionBlock:^{
        if (weakOperation.isCancelled) {
            return;
        }

        if (!self.isCachedLoaded) {
            [self loadFromCache];
        }

        NSError *error = nil;
        PostList *list;
        if (self.postTag) {
            list = [_imageBoard queryPostList:1 limit:page_limit tags:@[self.postTag.name] error:&error];
        } else {
            list = [_imageBoard queryPostList:1 limit:page_limit tags:nil error:&error];
        }

        if (weakOperation.isCancelled) {
            [UIHelper UIShowNetworkIndicator:NO];
            return;
        }

        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isLoadingLatest = NO;
                if (self.block != nil) {
                    self.block(self.list, YES, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isLoadingLatest = NO;
                self.list = list;
                _page = 1;
                if (self.block != nil) {
                    self.block(self.list, YES, nil);
                }
                [self saveToCache];
            });
        }
    }];
    self.currentLoadLatestOperation = operation;
    [self.queue addOperation:operation];
    return YES;
}

//only save latest cache(no post tag)
- (void)saveToCache {
    if (self.postTag) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
            (unsigned long) NULL), ^(void) {
        NSMutableArray *posts = [NSMutableArray arrayWithCapacity:50];
        int count = MIN(50, self.list.count);
        for (int i = 0; i < count; i++) {
            [posts addObject:[self.list getPostAt:i]];
        }
        [self.homeDB addPosts:posts];
    });
}

//only read latest cache(no post tag)
- (void)loadFromCache {
    if (self.postTag) {
        return;
    }
    self.homeDB = [[HomeDB alloc] init];
    Danbooru *danbooru = (Danbooru *) self.imageBoard;
    [self.homeDB open:danbooru.identifyId];
    NSArray *posts = [self.homeDB query];
    if (posts) {
        PostList *list = [[PostList alloc] init];
        list.posts = posts;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.list = list;
            if (self.block != nil) {
                self.block(self.list, NO, nil);
            }
        });
    }
    self.isCachedLoaded = YES;
}

- (BOOL)loadPreviousData {
    if (self.isLoadingLatest) {
        return NO;
    }
    if (self.isLoadingPrevious) {
        return YES;
    }

    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    if (time - self.previousRequestTime < 1) {
        return false;
    }
    self.previousRequestTime = time;

    self.isLoadingPrevious = YES;

    //for app store
    Danbooru *danbooru = (Danbooru *) _imageBoard;
    if (!danbooru.isUserConfig && self.page >= 6) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoadingPrevious = NO;
            if (self.block != nil) {
                self.block(self.list, YES, nil);
            }
        });
        return NO;
    }

    [UIHelper UIShowNetworkIndicator:YES];
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak typeof(operation) weakOperation = operation;
    [operation addExecutionBlock:^{
        if (weakOperation.isCancelled) {
            return;
        }

        NSError *error = nil;
        PostList *list;
        if (self.postTag) {
            list = [_imageBoard queryPostList:(self.page + 1) limit:page_limit tags:@[self.postTag.name] error:&error];
        } else {
            list = [_imageBoard queryPostList:(self.page + 1) limit:page_limit tags:nil error:&error];
        }

        if (weakOperation.isCancelled) {
            [UIHelper UIShowNetworkIndicator:NO];
            return;
        }

        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isLoadingPrevious = NO;
                if (self.block != nil) {
                    self.block(self.list, YES, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isLoadingPrevious = NO;
                [self.list addPosts:list.posts];
                _page += 1;
                if (self.block != nil) {
                    self.block(self.list, YES, nil);
                }
            });
        }
    }];
    self.currentLoadPreviousOperation = operation;
    [self.queue addOperation:operation];
    return YES;
}

@end
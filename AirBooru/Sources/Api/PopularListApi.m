//
// Created by qii on 7/9/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PopularListApi.h"
#import "PostList.h"
#import "UIHelper.h"
#import "Yandere.h"

static int const page_limit = 60;

@interface PopularListApi ()
@property(strong, nonatomic) NSOperationQueue *queue;
@property(assign, nonatomic) BOOL isRefreshing;
@property(assign, nonatomic) BOOL isLoadingPrevious;
@property(strong, nonatomic) PostList *list;
@end

@implementation PopularListApi

- (instancetype)init {
    self = [super init];
    if (self) {
        self.list = [[PostList alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.isRefreshing = NO;
        self.isLoadingPrevious = NO;
        _page = -1;
    }
    return self;
}

- (void)setImageBoard:(ImageBoard2 *)imageBoard {
    _imageBoard = imageBoard;
    _page = 0;
}

- (void)loadLatestData {
    if (self.isRefreshing) {
        return;
    }
    self.isRefreshing = YES;

    [UIHelper UIShowNetworkIndicator:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
            (unsigned long) NULL), ^(void) {
        NSError *error = nil;
        PostList *list = [_imageBoard queryPopularPostList:1 limit:page_limit period:self.period error:&error];

        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isRefreshing = NO;
                if (self.block != nil) {
                    self.block(self.list, YES, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isRefreshing = NO;
                self.list = list;
                _page = 1;
                if (self.block != nil) {
                    self.block(self.list, YES, nil);
                }
            });
        }
    });

}

@end
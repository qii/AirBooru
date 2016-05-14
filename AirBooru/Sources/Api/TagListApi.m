//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "TagListApi.h"
#import "TagList.h"
#import "ImageBoard2.h"
#import "UIHelper.h"
#import "Danbooru.h"

static int const page_limit = 60;

@interface TagListApi ()
@property(strong, nonatomic) NSOperationQueue *queue;
@property(assign, nonatomic) BOOL isRefreshing;
@property(assign, nonatomic) BOOL isLoadingPrevious;
@property(strong, nonatomic) TagList *list;
@property(assign, readonly, nonatomic) int page;

@property(nonatomic, assign) int tagPageLimit;
@end

@implementation TagListApi

- (instancetype)init {
    self = [super init];
    if (self) {
        self.list = [[TagList alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.isRefreshing = NO;
        self.isLoadingPrevious = NO;
        self.tagPageLimit = 200;
        _page = -1;
    }
    return self;
}

- (void)setImageBoard:(ImageBoard2 *)imageBoard {
    _imageBoard = imageBoard;
    _page = 0;
    Danbooru *danbooru = (Danbooru *) imageBoard;
    if (danbooru.isUserConfig) {
        self.tagPageLimit = 200;
    } else {
        self.tagPageLimit = 20;
    }
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
        TagList *list = [_imageBoard queryTagList:1 limit:self.tagPageLimit name:nil error:&error];
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isRefreshing = NO;
                if (self.block != nil) {
                    self.block(self.list, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isRefreshing = NO;
                self.list = list;
                _page = 1;
                if (self.block != nil) {
                    self.block(self.list, nil);
                }
            });
        }
    });
}

- (void)loadPreviousData {
    if (self.isLoadingPrevious) {
        return;
    }
    self.isLoadingPrevious = YES;

    [UIHelper UIShowNetworkIndicator:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
            (unsigned long) NULL), ^(void) {
        NSError *error = nil;
        TagList *list = [_imageBoard queryTagList:(self.page + 1) limit:self.tagPageLimit name:nil error:&error];

        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isLoadingPrevious = NO;
                if (self.block != nil) {
                    self.block(self.list, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                self.isLoadingPrevious = NO;
                [self.list addTags:list.tags];
                _page += 1;
                if (self.block != nil) {
                    self.block(self.list, nil);
                }
            });
        }
    });
}

- (void)searchTagName:(NSString *)tagName {
    [UIHelper UIShowNetworkIndicator:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
            (unsigned long) NULL), ^(void) {
        NSError *error = nil;
        TagList *list = [_imageBoard queryTagList:1 limit:self.tagPageLimit name:tagName error:&error];
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                if (self.searchBlock != nil) {
                    self.searchBlock(list, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIHelper UIShowNetworkIndicator:NO];
                if (self.searchBlock != nil) {
                    self.searchBlock(list, nil);
                }
            });
        }
    });
}

@end
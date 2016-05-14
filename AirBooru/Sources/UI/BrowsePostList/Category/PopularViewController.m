//
// Created by qii on 7/9/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PopularViewController.h"
#import "PostListApi.h"
#import "ImageBoard2.h"
#import "ToastView.h"
#import "PostList.h"
#import "Konachan.h"
#import "PopularListApi.h"
#import "ServersManager.h"

@interface PopularViewController ()
@property(nonatomic, strong) PopularListApi *api;
@property(nonatomic, copy) ABUServersManagerImageBoardChangeBlock changeBlock;
@end

@implementation PopularViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.canLoadMore = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak PopularViewController *weakSelf = self;
    self.changeBlock = ^void(ImageBoard2 *imageBoard) {
        weakSelf.api.imageBoard = imageBoard;
        [weakSelf.api loadLatestData];
    };
    [[ServersManager sharedInstance] addImageBoardChangedBlock:self.changeBlock];
    self.api = [[PopularListApi alloc] init];
    self.api.period = self.period;
    self.api.imageBoard = [ServersManager sharedInstance].imageBoard;

    self.api.block = ^void(PostList *postList, BOOL finished, NSError *error) {
        if (error != nil) {
            [ToastView toastWithTitle:error.localizedDescription];
        } else {
            weakSelf.postList = postList;
            [weakSelf.collectionView reloadData];
        }
        if (finished) {
            [weakSelf endRefreshing];
            [weakSelf endFooterRefreshing];
        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __strong PopularViewController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf loadLatestPostList];
        }
    });
}

- (void)loadLatestPostList {
    [self beginRefreshing];
    [self.api loadLatestData];
}

- (void)loadPreviousPostList {

}

@end
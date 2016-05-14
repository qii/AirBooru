//
// Created by qii on 7/7/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PostByTagViewController.h"
#import "PostListApi.h"
#import "ImageBoard2.h"
#import "ToastView.h"
#import "PostList.h"
#import "Tag.h"

@interface PostByTagViewController ()
@property(nonatomic, strong) PostListApi *api;
@end

@implementation PostByTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.api = [[PostListApi alloc] init];
    self.api.imageBoard = self.imageBoard;
    self.api.postTag = self.postTag;
    __weak PostByTagViewController *weakSelf = self;
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
    self.navigationItem.title = self.postTag.name;
    [self loadLatestPostList];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    __weak typeof(self) weakSelf = self;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        __strong PostByTagViewController *strongSelf = weakSelf;
//        if (strongSelf != nil) {
//            [strongSelf.refreshControl beginRefreshing];
//            [strongSelf.collectionView setContentOffset:CGPointMake(0, strongSelf.collectionView.contentOffset.y - strongSelf.refreshControl.frame.size.height)
//                                               animated:YES];
//            [strongSelf.api loadLatestData];
//        }
//    });
//}

- (void)loadLatestPostList {
    if ([self.api loadLatestData]) {
        [self beginRefreshing];
    } else {
        [self endRefreshing];
    }
}

- (void)loadPreviousPostList {
    if ([self.api loadPreviousData]) {
        [self beginFooterRefreshing];
    } else {
        [self endFooterRefreshing];
    }
}

@end
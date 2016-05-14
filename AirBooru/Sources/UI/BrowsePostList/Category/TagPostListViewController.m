//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "TagPostListViewController.h"
#import "PostListApi.h"
#import "ImageBoard2.h"
#import "ToastView.h"
#import "PostList.h"
#import "Tag.h"
#import "Konachan.h"
#import "ServersManager.h"

@interface TagPostListViewController ()
@property(nonatomic, strong) PostListApi *api;
@property(nonatomic, copy) ABUServersManagerImageBoardChangeBlock changeBlock;
@end

@implementation TagPostListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak TagPostListViewController *weakSelf = self;
    self.changeBlock = ^void(ImageBoard2 *imageBoard) {
        weakSelf.api.imageBoard = imageBoard;
        if ([weakSelf.api loadLatestData]) {
            [weakSelf beginRefreshing];
        } else {
            [weakSelf endRefreshing];
        }
    };
    [[ServersManager sharedInstance] addImageBoardChangedBlock:self.changeBlock];
    self.api = [[PostListApi alloc] init];
    self.api.imageBoard = [ServersManager sharedInstance].imageBoard;
    if (self.tagName) {
        Tag *tag = [[Tag alloc] init];
        tag.name = self.tagName;//@"order:score"
        self.api.postTag = tag;
    }
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
        __strong TagPostListViewController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf loadLatestPostList];
        }
    });
}

- (void)setTagName:(NSString *)tagName {
    _tagName = tagName;
    if (self.tagName) {
        Tag *tag = [[Tag alloc] init];
        tag.name = self.tagName;//@"order:score"
        self.api.postTag = tag;
    } else {
        self.api.postTag = nil;
    }
}

- (void)setImageBoard:(ImageBoard2 *)imageBoard {
    [super setImageBoard:imageBoard];
    self.api.imageBoard = self.imageBoard;
    [self loadLatestPostList];
}

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
//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PostListViewController.h"
#import "Post.h"
#import "ImageLoader.h"
#import "BrowsePostViewController.h"
#import "PostList.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "PostCell.h"
#import "FixUIRefreshUICollectionView.h"
#import "MJRefresh.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "ThemeHelper.h"
#import "FavouriteDB.h"
#import "ToastView.h"

@interface PostListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@property(nonatomic, strong) MJRefreshNormalHeader *header;
@property(nonatomic, strong) MJRefreshBackNormalFooter *footer;
@property(nonatomic, strong) UILabel *emptyTipLabel;
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation PostListViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.canLoadMore = YES;
        self.emptyTip = @"No data is currently available. Please pull down to refresh.";
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView = [[FixUIRefreshUICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left).offset(2);
        make.right.equalTo(self.view.mas_right).offset(-2);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    if (!self.hidesBottomBarWhenPushed) {
        self.collectionView.contentInset = UIEdgeInsetsMake(64 + 2, 0, 49 + 2, 0);
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(64 + 2, 0, 2, 0);
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    self.automaticallyAdjustsScrollViewInsets = NO;

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat screenWidth = screenRect.size.width - 2 - 2 - 2 - 2;
    CGFloat width = screenWidth / 3;
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;

    [self.collectionView registerClass:[PostCell class] forCellWithReuseIdentifier:@"PostCell"];
    self.collectionView.alwaysBounceVertical = YES;

    [self addPullDownToRefresh];
    if (self.canLoadMore) {
        [self addPullUpToLoadMore];
    }

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    self.emptyTipLabel = [UILabel new];
    self.emptyTipLabel.text = self.emptyTip;
    self.emptyTipLabel.textColor = [UIColor blackColor];
    self.emptyTipLabel.numberOfLines = 0;
    self.emptyTipLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyTipLabel sizeToFit];

    [self.view addSubview:self.emptyTipLabel];
    [self.emptyTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.collectionView.mas_centerX);
        make.centerY.equalTo(self.collectionView.mas_centerY);
        make.width.equalTo(self.collectionView.mas_width).offset(-20);
        make.height.greaterThanOrEqualTo(@1);
    }];
    __weak typeof(self) weakSelf = self;
    self.emptyTipLabel.userInteractionEnabled = YES;
    [self.emptyTipLabel addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [weakSelf loadLatestPostList];
    }]];
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    self.longPressGestureRecognizer.minimumPressDuration = 1;
    self.longPressGestureRecognizer.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Long press

- (void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"couldn't find index path");
    } else {
        [self collectionView:self.collectionView didLongSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didLongSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *favourite = nil;
    Post *post = [self.postList getPostAt:indexPath.row];
    FavouriteDB *favouriteDB = [FavouriteDB sharedInstance];
    if (![favouriteDB isFavourite:post.postId]) {
        favourite = [UIAlertAction actionWithTitle:@"Favourite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [favouriteDB addPost:post];
            [ToastView toastWithTitle:@"Favourite successfully"];
        }];
    } else {
        favourite = [UIAlertAction actionWithTitle:@"UnFavourite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [favouriteDB deletePost:post.postId];
            [ToastView toastWithTitle:@"UnFavourite successfully"];
        }];
    }

    UIAlertAction *report = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self fakeReport];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];

    [actionSheetController addAction:favourite];
    [actionSheetController addAction:report];
    [actionSheetController addAction:cancel];
    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (void)fakeReport {
    UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:@"Report"
                             message:@"Are you sure you want to report this post?"
                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:@"Report"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) {
                        [self performSelector:@selector(fakeReportImp) withObject:[UIColor blueColor] afterDelay:1];
                    }];
    UIAlertAction *cancelAction = [UIAlertAction
            actionWithTitle:@"Cancel"
                      style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction *action) {

                    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)fakeReportImp {
    [ToastView toastWithTitle:@"Report successfully"];
}

- (void)addPullDownToRefresh {
    if (!self.collectionView) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadLatestPostList];
    }];
    self.header.lastUpdatedTimeLabel.hidden = YES;
    [self.header setTitle:@"Pull down" forState:MJRefreshStateIdle];
    [self.header setTitle:@"Release" forState:MJRefreshStatePulling];
    [self.header setTitle:@"Loading" forState:MJRefreshStateRefreshing];
    self.collectionView.header = self.header;
}

- (void)addPullUpToLoadMore {
    if (!self.collectionView) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadPreviousPostList];
    }];
    [self.footer setTitle:@"Pull up" forState:MJRefreshStateIdle];
    [self.footer setTitle:@"Release" forState:MJRefreshStatePulling];
    [self.footer setTitle:@"Loading" forState:MJRefreshStateRefreshing];
    self.collectionView.footer = self.footer;
}

- (void)removePullUpToLoadMore {
    self.footer = nil;
    self.collectionView.footer = nil;
}

- (void)setEmptyTip:(NSString *)emptyTip {
    _emptyTip = emptyTip;
    self.emptyTipLabel.text = _emptyTip;
}

- (void)setCanLoadMore:(BOOL)canLoadMore {
    _canLoadMore = canLoadMore;
    if (_canLoadMore) {
        [self addPullUpToLoadMore];
    } else {
        [self removePullUpToLoadMore];
    }
}

#pragma mark - Subclass override method

- (void)loadLatestPostList {

}

- (void)loadPreviousPostList {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refreshing widget status

- (void)beginRefreshing {
    //check collectionview contentoffset to avoid a new refresh animation and refresh event
    if (!self.header.isRefreshing && self.collectionView.contentOffset.y <= 0) {
        [self.header beginRefreshing];
    }
    self.emptyTipLabel.hidden = YES;
}

- (void)endRefreshing {
    [self.header endRefreshing];
    if (self.postList && self.postList.count > 0) {
        self.footer.hidden = NO;
        self.emptyTipLabel.hidden = YES;
    } else {
        self.footer.hidden = YES;
        self.emptyTipLabel.hidden = NO;
    }
}

- (void)beginFooterRefreshing {
    [self.footer beginRefreshing];
}

- (void)endFooterRefreshing {
    [self.footer endRefreshing];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.postList && self.postList.count > 0) {
        return self.postList.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *postCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
    Post *post = self.postList[indexPath.row];
    postCell.post = post;
    return postCell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.postList != nil && indexPath.row <= self.postList.count - 1) {
        Post *post = [self.postList getPostAt:indexPath.row];
        NSString *thumbnail = post.preview_url;
        [[ImageLoader sharedInstance] cancelLoadImage:thumbnail];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BrowsePostViewController *controller = [BrowsePostViewController viewControllerWithPostList:self.postList index:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
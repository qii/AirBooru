//
// Created by qii on 5/17/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "TagsViewController.h"
#import "RootViewController.h"
#import "TagListApi.h"
#import "Konachan.h"
#import "ToastView.h"
#import "TagList.h"
#import "Tag.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "TagCell.h"
#import "PostByTagViewController.h"
#import "ServersManager.h"
#import "FixUIRefreshUITableView.h"
#import "ThemeHelper.h"
#import "MJRefresh.h"

@interface TagsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property(nonatomic, strong) MJRefreshNormalHeader *header;
@property(nonatomic, strong) UISearchDisplayController *searchController;

@property(nonatomic, strong) TagListApi *api;
@property(nonatomic, strong) TagList *tagList;
@property(nonatomic, strong) TagList *searchTagList;

@property(nonatomic, copy) ABUServersManagerImageBoardChangeBlock changeBlock;
@end

@implementation TagsViewController

+ (UINavigationController *)viewControllerFromStoryboard {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:NSStringFromClass([TagsViewController class]) bundle:nil];
    UINavigationController *controller = [storyBoard instantiateInitialViewController];
    return controller;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView = [[FixUIRefreshUITableView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(64 + 2, 0, 49 + 2, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    __weak typeof(self) weakSelf = self;
    self.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf reloadPostList];
    }];
    self.header.lastUpdatedTimeLabel.hidden = YES;
    [self.header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];
    [self.header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [self.header setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
    self.tableView.header = self.header;

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"Search";
    searchBar.delegate = self;

    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;

    // 用 searchbar 初始化 SearchDisplayController
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    [ThemeHelper fixSearchBarHeaderViewBackgroundColorBug:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;

    self.title = @"Tags";
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
//            initWithImage:[ImageHelper scaleImageToSize:[UIImage imageNamed:@"menu_50.png"] size:CGSizeMake(30, 30)] style:UIBarButtonItemStylePlain
//                   target:self action:@selector(showMenuBar:)];
//    self.navigationItem.leftBarButtonItem = menuButton;

//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
//            initWithImage:[UIImage imageNamed:@"navigationbar_list"] style:UIBarButtonItemStylePlain
//                   target:self action:@selector(showMenuBar:)];
//    self.navigationItem.leftBarButtonItem = menuButton;

//    UIBarButtonItem *poolButton= [[UIBarButtonItem alloc] initWithTitle:@"Pools" style:UIBarButtonItemStylePlain target:self action:@selector(pool)];
//    self.navigationItem.rightBarButtonItem=poolButton;
    __weak TagsViewController *weakSelf = self;
    self.changeBlock = ^void(ImageBoard2 *imageBoard) {
        weakSelf.api.imageBoard = imageBoard;
        [weakSelf.api loadLatestData];
    };
    [[ServersManager sharedInstance] addImageBoardChangedBlock:self.changeBlock];
    self.api = [[TagListApi alloc] init];
    self.api.imageBoard = [ServersManager sharedInstance].imageBoard;
    self.api.block = ^void(TagList *tagList, NSError *error) {
        [weakSelf.header endRefreshing];
        [weakSelf removeLoadProgress];
        if (error != nil) {
            [ToastView toastWithTitle:error.localizedDescription];
        } else {
            weakSelf.tagList = tagList;
            [weakSelf.tableView reloadData];
        }
    };
    self.api.searchBlock = ^void(TagList *tagList, NSError *error) {
        if (error != nil) {
            [ToastView toastWithTitle:error.localizedDescription];
        } else {
            weakSelf.searchTagList = tagList;
            [weakSelf.searchController.searchResultsTableView reloadData];
        }
    };
    [self.header beginRefreshing];
    [self.api loadLatestData];
}

- (void)reloadPostList {
    [self.api loadLatestData];
}

- (void)addLoadProgress {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
    self.tableView.tableFooterView = spinner;
}

- (void)removeLoadProgress {
    self.tableView.tableFooterView = nil;
}

- (void)showMenuBar:(id)OnSideBarButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.api searchTagName:searchBar.text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchController.searchResultsTableView) {
        if (self.searchTagList != nil) {
            return [self.searchTagList.tags count];
        } else {
            return 0;
        }
    } else {
        if (self.tagList != nil) {
            return [self.tagList.tags count];
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"TagCell";
    TagCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[TagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    Tag *tag;
    if (tableView == self.searchController.searchResultsTableView) {
        tag = [self.searchTagList getTagAt:indexPath.row];
    } else {
        tag = [self.tagList getTagAt:indexPath.row];
    }
    cell.postTag = tag;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.tagList == nil) {
//        return;
//    }
//    if (indexPath.row == self.tagList.tags.count - 1) {
//        [self addLoadProgress];
//        [self.api loadPreviousData];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tag *tag;
    if (tableView == self.searchController.searchResultsTableView) {
        tag = [self.searchTagList getTagAt:indexPath.row];
    } else {
        tag = [self.tagList getTagAt:indexPath.row];
    }
    PostByTagViewController *controller = [[PostByTagViewController alloc] init];
    controller.imageBoard = self.api.imageBoard;
    controller.postTag = tag;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
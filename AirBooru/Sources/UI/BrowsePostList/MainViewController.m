//
//  MainViewController.m
//  AirBooru
//
//  Created by qii on 4/24/15.
//  Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//


#import "MainViewController.h"
#import "PostList.h"
#import "PostListApi.h"
#import "ToastView.h"
#import "OHActionSheet.h"
#import "RootViewController.h"
#import "Konachan.h"
#import "Yandere.h"
#import "Safebooru.h"


@interface MainViewController ()
@property(strong, nonatomic) PostListApi *api;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.title = @"AirBooru";

//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
//                                   initWithImage:[ImageHelper scaleImageToSize:[UIImage imageNamed:@"menu_50.png"] size:CGSizeMake(30, 30)] style:UIBarButtonItemStylePlain
//                                   target:self action:@selector(showMenuBar:)];
//    self.navigationItem.leftBarButtonItem = menuButton;


    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"navigationbar_list"] style:UIBarButtonItemStylePlain
                   target:self action:@selector(listCategory)];
    self.navigationItem.leftBarButtonItem = menuButton;

//    UIBarButtonItem *switchServerButton = [[UIBarButtonItem alloc] initWithTitle:@"Servers" style:UIBarButtonItemStylePlain target:self action:@selector(servers)];
//    self.navigationItem.rightBarButtonItem = switchServerButton;
    UIBarButtonItem *switchServerButton = [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"navigationbar_server"] style:UIBarButtonItemStylePlain
                   target:self action:@selector(servers)];
    self.navigationItem.rightBarButtonItem = switchServerButton;

    [self installTitle];
    [self setHeaderTitle:@"AirBooru" andSubtitle:@"Konachan"];


    self.api = [[PostListApi alloc] init];
    self.api.imageBoard = [[Konachan alloc] init];
    __weak MainViewController *weakSelf = self;
    self.api.block = ^void(PostList *postList, BOOL finished, NSError *error) {
        [weakSelf endRefreshing];
        if (error != nil) {
            [ToastView toastWithTitle:error.localizedDescription];
        } else {
            weakSelf.postList = postList;
            [weakSelf.collectionView reloadData];
        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __strong MainViewController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf beginRefreshing];
//            [strongSelf.api loadLatestData];
        }
    });
}

- (void)loadLatestPostList {
    [self beginRefreshing];
//    [self.api loadLatestData];
}

- (void)loadPreviousPostList {
//    [self.api loadPreviousData];
}


#pragma mark - Title

- (void)installTitle {
    CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, 200, 44);
    UIView *_headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    //    _headerTitleSubtitleView.autoresizesSubviews = YES;

    CGRect titleFrame = CGRectMake(0, 2, 200, 24);
    UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:18];
    titleView.textAlignment = UITextAlignmentCenter;
    titleView.textColor = [UIColor blackColor];
    //    titleView.shadowColor = [UIColor darkGrayColor];
    //    titleView.shadowOffset = CGSizeMake(0, -1);
    titleView.text = @"Title";
    titleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:titleView];

    CGRect subtitleFrame = CGRectMake(0, 24, 200, 44 - 24);
    UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont boldSystemFontOfSize:13];
    subtitleView.textAlignment = UITextAlignmentCenter;
    subtitleView.textColor = [UIColor blackColor];
    subtitleView.shadowColor = [UIColor whiteColor];
    subtitleView.shadowOffset = CGSizeMake(0, -1);
    subtitleView.text = @"Subtitle";
    subtitleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:subtitleView];

    self.navigationItem.titleView = _headerTitleSubtitleView;
}


- (void)setHeaderTitle:(NSString *)headerTitle andSubtitle:(NSString *)headerSubtitle {
    assert(self.navigationItem.titleView != nil);
    UIView *headerTitleSubtitleView = self.navigationItem.titleView;
    UILabel *titleView = [headerTitleSubtitleView.subviews objectAtIndex:0];
    UILabel *subtitleView = [headerTitleSubtitleView.subviews objectAtIndex:1];
    assert((titleView != nil) && (subtitleView != nil) && ([titleView isKindOfClass:[UILabel class]]) && ([subtitleView isKindOfClass:[UILabel class]]));
    titleView.text = headerTitle;
    subtitleView.text = headerSubtitle;
}

#pragma mark - Action

- (void)showMenuBar:(id)OnSideBarButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
}

- (void)listCategory {
    OHActionSheet *sheet = [[OHActionSheet alloc] initWithTitle:@"Category"
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@[@"Latest", @"Score", @"Random", @"Popular (by day)", @"Popular (by week)", @"Popular (by month)"]
                                                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {
                                                         switch (buttonIndex) {
                                                             case 0:
                                                                 self.api.imageBoard = [[Yandere alloc] init];
                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Yande.re"];
                                                                 break;
                                                             case 1:
                                                                 self.api.imageBoard = [[Konachan alloc] init];
                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Konachan"];
                                                                 break;
                                                             case 2:
                                                                 self.api.imageBoard = [[Safebooru alloc] init];
                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Safebooru"];
                                                                 break;
                                                         }
//                                                         [self.api loadLatestData];
                                                     }];
    [sheet showFromView:self.view];
}

- (void)servers {
    //    SettingViewController *controller = [SettingViewController viewControllerFromStoryBoard];
    //    [self.navigationController pushViewController:controller animated:YES];
    OHActionSheet *sheet = [[OHActionSheet alloc] initWithTitle:@"Servers"
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@[@"Yande.re", @"Konachan", @"Safebooru"]
                                                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {
                                                         switch (buttonIndex) {
                                                             case 0:
                                                                 self.api.imageBoard = [[Yandere alloc] init];
                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Yande.re"];
                                                                 break;
                                                             case 1:
                                                                 self.api.imageBoard = [[Konachan alloc] init];
                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Konachan"];
                                                                 break;
                                                             case 2:
                                                                 self.api.imageBoard = [[Safebooru alloc] init];
                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Safebooru"];
                                                                 break;
                                                         }
//                                                         [self.api loadLatestData];
                                                     }];
    [sheet showFromView:self.view];
}

@end
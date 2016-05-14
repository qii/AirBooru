//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "HomeViewController.h"
#import "MainViewController.h"
#import "TagPostListViewController.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "PopularViewController.h"
#import "ThemeHelper.h"
#import "Konachan.h"
#import "ServersManager.h"

static NSString *const AppStoreTag = @"durarara!!";

@interface HomeViewController ()
@property(nonatomic, strong) PostListViewController *currentChildViewController;
@property(nonatomic, assign) int currentChildIndex;
@end

@implementation HomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentChildIndex = -1;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.tintColor = [ThemeHelper tintColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
            initWithImage:[[UIImage imageNamed:@"navigationbar_list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain
                   target:self action:@selector(listCategory)];
    menuButton.tintColor = [ThemeHelper tintColor];
    self.navigationItem.leftBarButtonItem = menuButton;

    UIBarButtonItem *switchServerButton = [[UIBarButtonItem alloc]
            initWithImage:[[UIImage imageNamed:@"navigationbar_server"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain
                   target:self action:@selector(servers)];
    switchServerButton.tintColor = [ThemeHelper tintColor];
    self.navigationItem.rightBarButtonItem = switchServerButton;

    [self installTitle];
    [self setHeaderTitle:@"AirBooru" andSubtitle:@"Konachan"];

    [self switchToCategory:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"airbooru_first_start_tip"]) {
        [self showTipDialog];
        [defaults setBool:YES forKey:@"airbooru_first_start_tip"];
        [defaults synchronize];
    }
}

- (void)showTipDialog {
    UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:@"Welcome!"
                             message:@"Manage your servers in Settings - Manage Servers options."
                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) {

                    }];

    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addChildVC:(UIViewController *)controller {
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [controller didMoveToParentViewController:self];
}

- (void)removeChildVC:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller removeFromParentViewController];
    [controller.view removeFromSuperview];
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

- (void)listCategory {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Category",nil)
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    if (![ServersManager sharedInstance].imageBoard.isUserConfig) {
        [@[@"Default"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = (NSString *) obj;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self switchToCategory:idx];
            }];
            [actionSheetController addAction:action];
        }];
    } else {
        [@[NSLocalizedString(@"Latest",nil), NSLocalizedString(@"Score",nil), NSLocalizedString(@"Random",nil), NSLocalizedString(@"Popular (by day)",nil), NSLocalizedString(@"Popular (by week)",nil), NSLocalizedString(@"Popular (by month)",nil), NSLocalizedString(@"Popular (by year)",nil)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = (NSString *) obj;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self switchToCategory:idx];
            }];
            [actionSheetController addAction:action];
        }];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];

    [actionSheetController addAction:cancel];
    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
//    OHActionSheet *sheet = [[OHActionSheet alloc] initWithTitle:@"Category"
//                                              cancelButtonTitle:@"Cancel"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@[@"Latest", @"Score", @"Random", @"Popular (by day)", @"Popular (by week)", @"Popular (by month)", @"Popular (by year)"]
//                                                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {
//                                                         [self switchToCategory:buttonIndex];
//                                                     }];
//    [sheet showFromView:self.view];
}

- (void)switchToCategory:(int)index {
    if (self.currentChildIndex == index || index >= 7 || index < 0) {
        return;
    }
    self.currentChildIndex = index;

    if (self.currentChildViewController != nil) {
        [self removeChildVC:self.currentChildViewController];
    }

    PostListViewController *postListViewController;
    switch (index) {
        case 0: {
            TagPostListViewController *scoreViewController = [[TagPostListViewController alloc] init];
            NSString *subTitle;
            if (![ServersManager sharedInstance].imageBoard.isUserConfig) {
                scoreViewController.tagName = AppStoreTag;
                subTitle = [NSString stringWithFormat:@"%@", [ServersManager sharedInstance].imageBoard.name];
            } else {
                subTitle = [NSString stringWithFormat:@"%@ latest", [ServersManager sharedInstance].imageBoard.name];
                scoreViewController.tagName = nil;
            }
            postListViewController = scoreViewController;
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
        case 1: {
            TagPostListViewController *scoreViewController = [[TagPostListViewController alloc] init];
            scoreViewController.tagName = @"order:score";
            postListViewController = scoreViewController;
            NSString *subTitle = [NSString stringWithFormat:@"%@ score", [ServersManager sharedInstance].imageBoard.name];
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
        case 2: {
            TagPostListViewController *scoreViewController = [[TagPostListViewController alloc] init];
            scoreViewController.tagName = @"order:random";
            postListViewController = scoreViewController;
            NSString *subTitle = [NSString stringWithFormat:@"%@ random", [ServersManager sharedInstance].imageBoard.name];
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
        case 3: {
            PopularViewController *popularViewController = [[PopularViewController alloc] init];
            popularViewController.period = nil;
            postListViewController = popularViewController;
            NSString *subTitle = [NSString stringWithFormat:@"%@ popular by day", [ServersManager sharedInstance].imageBoard.name];
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
        case 4: {
            PopularViewController *popularViewController = [[PopularViewController alloc] init];
            popularViewController.period = @"1w";
            postListViewController = popularViewController;
            NSString *subTitle = [NSString stringWithFormat:@"%@ popular by week", [ServersManager sharedInstance].imageBoard.name];
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
        case 5: {
            PopularViewController *popularViewController = [[PopularViewController alloc] init];
            popularViewController.period = @"1m";
            postListViewController = popularViewController;
            NSString *subTitle = [NSString stringWithFormat:@"%@ popular by month", [ServersManager sharedInstance].imageBoard.name];
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
        case 6: {
            PopularViewController *popularViewController = [[PopularViewController alloc] init];
            popularViewController.period = @"1y";
            postListViewController = popularViewController;
            NSString *subTitle = [NSString stringWithFormat:@"%@ popular by year", [ServersManager sharedInstance].imageBoard.name];
            [self setHeaderTitle:@"AirBooru" andSubtitle:subTitle];
            break;
        }
    }

    self.currentChildViewController = postListViewController;
    [self addChildVC:self.currentChildViewController];
    [self.currentChildViewController loadLatestPostList];
}

- (void)servers {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableArray *servers = [ServersManager sharedInstance].imageBoardArray;
    for (Danbooru *danbooru in servers) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:danbooru.isUserConfig ? danbooru.name : [NSString stringWithFormat:@"%@(default)", danbooru.name] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self setHeaderTitle:@"AirBooru" andSubtitle:danbooru.name];
            if ([self.currentChildViewController isKindOfClass:[TagPostListViewController class]] && ![ServersManager sharedInstance].imageBoard.isUserConfig) {
                TagPostListViewController *scoreViewController = (TagPostListViewController *) self.currentChildViewController;
                if ([scoreViewController.tagName isEqualToString:AppStoreTag]) {
                    scoreViewController.tagName = nil;
                }
            }
            [ServersManager sharedInstance].imageBoard = danbooru;
        }];
        [actionSheetController addAction:alertAction];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];
    [actionSheetController addAction:cancel];

    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
//
//    //    SettingViewController *controller = [SettingViewController viewControllerFromStoryBoard];
//    //    [self.navigationController pushViewController:controller animated:YES];
//    OHActionSheet *sheet = [[OHActionSheet alloc] initWithTitle:@"Servers"
//                                              cancelButtonTitle:@"Cancel"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@[@"Yande.re", @"Konachan", @"Safebooru"]
//                                                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {
//                                                         switch (buttonIndex) {
//                                                             case 0:
////                                                                 self.api.imageBoard = [[Yandere alloc] init];
//                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Yande.re"];
//                                                                 break;
//                                                             case 1:
////                                                                 self.api.imageBoard = [[Konachan alloc] init];
//                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Konachan"];
//                                                                 break;
//                                                             case 2:
////                                                                 self.api.imageBoard = [[Safebooru alloc] init];
//                                                                 [self setHeaderTitle:@"AirBooru" andSubtitle:@"Safebooru"];
//                                                                 break;
//                                                         }
////                                                         [self.api loadLatestData];
//                                                     }];
//    [sheet showFromView:self.view];
}

- (void)scrollContentToTop {
    if (self.currentChildViewController) {
        UICollectionView *collectionView = self.currentChildViewController.collectionView;
        [collectionView setContentOffset:CGPointMake(-collectionView.contentInset.left, -collectionView.contentInset.top) animated:YES];
    }
}

@end
//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "RootTabViewController.h"
#import "RootTabNavigationController.h"
#import "HomeViewController.h"
#import "FavouriteViewController.h"
#import "ThemeHelper.h"
#import "Setting2ViewController.h"
#import "Tag2ViewController.h"

#define kColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]


@interface RootTabViewController ()
@property(nonatomic, strong) HomeViewController *homeViewController;
@property(nonatomic, strong) Tag2ViewController *tagViewController;
@property(nonatomic, strong) FavouriteViewController *favouriteViewController;
@property(nonatomic, strong) Setting2ViewController *settingViewController;

@property(nonatomic, assign) int index;
@end

@implementation RootTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    _homeViewController = [[HomeViewController alloc] init];
    [self addChildController:_homeViewController title:NSLocalizedString(@"Home",nil) image:@"tabbar_home"];

    _tagViewController = [[Tag2ViewController alloc] init];
    [self addChildController:_tagViewController title:NSLocalizedString(@"Tags",nil) image:@"tabbar_tag"];

    _favouriteViewController = [[FavouriteViewController alloc] init];
    [self addChildController:_favouriteViewController title:NSLocalizedString(@"Favourite",nil) image:@"tabbar_favourite"];

    _settingViewController = [[Setting2ViewController alloc] init];
    [self addChildController:_settingViewController title:NSLocalizedString(@"Settings",nil) image:@"tabbar_settings"];
}

- (void)addChildController:(UIViewController *)childViewController title:(NSString *)title image:(NSString *)image {
    childViewController.title = title;
    childViewController.tabBarItem.image = [UIImage imageNamed:image];
    childViewController.tabBarItem.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", image, @"_selected"]];
    self.tabBar.tintColor = [ThemeHelper tintColor];
    [childViewController.tabBarItem                     setTitleTextAttributes:
            @{NSForegroundColorAttributeName : kColor(117, 117, 117)} forState:UIControlStateNormal];
    [childViewController.tabBarItem                       setTitleTextAttributes:
            @{NSForegroundColorAttributeName : [ThemeHelper tintColor]} forState:UIControlStateSelected];

    UINavigationController *navigationController = [[RootTabNavigationController alloc] initWithRootViewController:childViewController];
    [self addChildViewController:navigationController];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int index = [tabBar.items indexOfObject:item];
    if (index == self.index) {
        [self scrollChildViewControllerToTop:self.index];
    }
    self.index = index;
}

- (void)scrollChildViewControllerToTop:(int)index {
    if (index == 0) {
        [self.homeViewController scrollContentToTop];
    } else if (index == 1) {
        [self.tagViewController scrollContentToTop];
    } else if (index == 2) {
        UICollectionView *collectionView = self.favouriteViewController.collectionView;
        [collectionView setContentOffset:CGPointMake(-collectionView.contentInset.left, -collectionView.contentInset.top) animated:YES];
    }
}
@end
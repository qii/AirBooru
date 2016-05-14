//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "SearchViewController.h"
#import "ImageHelper.h"
#import "RootViewController.h"

@interface SearchViewController ()
@property(nonatomic, strong) UISearchBar *searchBar;
@end

@implementation SearchViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search";
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
            initWithImage:[ImageHelper scaleImageToSize:[UIImage imageNamed:@"menu_50.png"] size:CGSizeMake(30, 30)] style:UIBarButtonItemStylePlain
                   target:self action:@selector(showMenuBar:)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)showMenuBar:(id)OnSideBarButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
}
@end
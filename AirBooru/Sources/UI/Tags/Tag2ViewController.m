//
// Created by qii on 7/28/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Tag2ViewController.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "ThemeHelper.h"
#import "TVTagsViewController.h"
#import "TagsViewController.h"
#import "ServersManager.h"

@interface Tag2ViewController ()
@property(nonatomic, strong) UIViewController *currentChildViewController;
@property(nonatomic, assign) int currentChildIndex;
@end

@implementation Tag2ViewController

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
    [self switchToCategory:0];
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

#pragma mark - Action

- (void)listCategory {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Category"
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    if (![ServersManager sharedInstance].imageBoard.isUserConfig) {
        [@[@"TV series"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = (NSString *) obj;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self switchToCategory:idx];
            }];
            [actionSheetController addAction:action];
        }];
    } else {
        [@[@"TV series", @"Tags (by count)"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *title = (NSString *) obj;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self switchToCategory:idx];
            }];
            [actionSheetController addAction:action];
        }];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];

    [actionSheetController addAction:cancel];
    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (void)switchToCategory:(int)index {
    if (self.currentChildIndex == index || index >= 7 || index < 0) {
        return;
    }
    self.currentChildIndex = index;

    if (self.currentChildViewController != nil) {
        [self removeChildVC:self.currentChildViewController];
    }

    UIViewController *postListViewController;
    switch (index) {
        case 0: {
            TVTagsViewController *tvTagsViewController = [[TVTagsViewController alloc] init];
            postListViewController = tvTagsViewController;
            break;
        }
        case 1: {
            TagsViewController *tagsViewController = [[TagsViewController alloc] init];
            postListViewController = tagsViewController;
            break;
        }
    }

    self.currentChildViewController = postListViewController;
    [self addChildVC:self.currentChildViewController];
}

- (void)scrollContentToTop {
    if (self.currentChildIndex == 0) {
        UITableView *tableView = ((TVTagsViewController *) self.currentChildViewController).tableView;
        [tableView setContentOffset:CGPointMake(-tableView.contentInset.left, -tableView.contentInset.top) animated:YES];
    } else {
        UITableView *tableView = ((TagsViewController *) self.currentChildViewController).tableView;
        [tableView setContentOffset:CGPointMake(-tableView.contentInset.left, -tableView.contentInset.top) animated:YES];
    }
}

@end
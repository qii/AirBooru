//
// Created by qii on 5/12/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "TagsViewController.h"
#import "MenuView.h"
#import "SearchViewController.h"
#import "SettingViewController.h"

static CGFloat const kMenuWidth = 240.0;

@interface RootViewController () <UIGestureRecognizerDelegate>
@property(strong, nonatomic) UINavigationController *mainViewController;
@property(strong, nonatomic) UINavigationController *tagsViewController;
@property(strong, nonatomic) UINavigationController *searchViewController;
@property(strong, nonatomic) UINavigationController *settingViewController;

@property(strong, nonatomic) IBOutlet MenuView *menuView;
@property(strong, nonatomic) IBOutlet UIView *menuViewBackground;
@property(strong, nonatomic) IBOutlet UIView *viewControllerContainerView;

@property(strong, nonatomic) UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer;
@property(assign, nonatomic) NSInteger currentSelectedIndex;
@end

@implementation RootViewController

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.currentSelectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];


//    self.mainViewController = [MainViewController viewControllerFromStoryboard];
    [self addChildVC:self.mainViewController];

    self.tagsViewController = [TagsViewController viewControllerFromStoryboard];
    [self addChildVC:self.tagsViewController];
    self.tagsViewController.view.hidden = YES;

    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    self.searchViewController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self addChildVC:self.searchViewController];
    self.searchViewController.view.hidden = YES;

    SettingViewController *settingViewController = [SettingViewController viewControllerFromStoryBoard];
    self.settingViewController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    [self addChildVC:self.settingViewController];
    self.settingViewController.view.hidden = YES;

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.edgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanRecognizer:)];
    self.edgePanGestureRecognizer.edges = UIRectEdgeLeft;
    self.edgePanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.edgePanGestureRecognizer];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    panRecognizer.delegate = self;
    [self.menuViewBackground addGestureRecognizer:panRecognizer];

    self.menuViewBackground.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    __weak typeof(self) weakSelf = self;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        __strong RootViewController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [UIView animateWithDuration:0.3 animations:^{
                [strongSelf setMenuOffset:0];
            }                completion:^(BOOL finished) {
                strongSelf.menuViewBackground.hidden = YES;
            }];
        }
    }];
    [self.menuViewBackground addGestureRecognizer:tapGestureRecognizer];

    [self.menuView setDidSelectedIndexBlock:^(NSInteger index) {
        [self showViewControllerAtIndex:index animated:YES];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveShowMenuNotification) name:kShowMenuNotification object:nil];
}

- (void)didReceiveShowMenuNotification {
    self.menuViewBackground.alpha = 0.0f;
    self.menuViewBackground.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self setMenuOffset:kMenuWidth];
    }                completion:^(BOOL finished) {
        self.menuViewBackground.alpha = 1.0f;
    }];
}

- (void)handlePanRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:self.menuViewBackground].x / (self.menuViewBackground.bounds.size.width * 0.5);
    progress = -MIN(progress, 0);

    [self setMenuOffset:kMenuWidth - kMenuWidth * progress];

    static CGFloat sumProgress = 0;
    static CGFloat lastProgress = 0;

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        sumProgress = 0;
        lastProgress = 0;
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (progress > lastProgress) {
            sumProgress += progress;
        } else {
            sumProgress -= progress;
        }
        lastProgress = progress;
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3 animations:^{
            if (sumProgress > 0.1) {
                [self setMenuOffset:0];
            } else {
                [self setMenuOffset:kMenuWidth];
            }
        }                completion:^(BOOL finished) {
            if (sumProgress > 0.1) {
                self.menuViewBackground.hidden = YES;
            } else {
                self.menuViewBackground.hidden = NO;
            }
        }];
    }
}

//todo why setMenuOff can't set in viewDidLoad
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setMenuOffset:0];
}

- (void)handleEdgePanRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / kMenuWidth;
    progress = MIN(1.0, MAX(0.0, progress));

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.menuViewBackground.hidden = NO;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self setMenuOffset:kMenuWidth * progress];

    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocity = [recognizer velocityInView:self.view].x;
        if (velocity > 20 || progress > 0.5) {

            [UIView animateWithDuration:(1 - progress) / 1.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self setMenuOffset:kMenuWidth];
            }                completion:^(BOOL finished) {;
            }];
        } else {
            [UIView animateWithDuration:progress / 3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setMenuOffset:0];
            }                completion:^(BOOL finished) {
                self.menuViewBackground.hidden = YES;
                self.menuViewBackground.alpha = 0.0;
            }];
        }
    }
}

- (void)setMenuOffset:(CGFloat)offset {
    CGRect frame = self.menuView.frame;
    frame.origin.x = offset - kMenuWidth;
    self.menuView.frame = frame;
    self.menuViewBackground.alpha = offset / kMenuWidth;
    //todo 如果去掉这个，那么有可能下个页面右滑返回后，立刻导致menuview显示，非常奇怪
    self.menuView.hidden = self.menuViewBackground.alpha == 0;
}

- (void)showViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index == 0) {
        self.mainViewController.view.hidden = NO;
        self.tagsViewController.view.hidden = YES;
        self.searchViewController.view.hidden = YES;
        self.settingViewController.view.hidden = YES;
    } else if (index == 1) {
        self.mainViewController.view.hidden = YES;
        self.tagsViewController.view.hidden = NO;
        self.searchViewController.view.hidden = YES;
        self.settingViewController.view.hidden = YES;
    } else if (index == 2) {
        self.mainViewController.view.hidden = YES;
        self.tagsViewController.view.hidden = YES;
        self.searchViewController.view.hidden = NO;
        self.settingViewController.view.hidden = YES;
    } else {
        self.mainViewController.view.hidden = YES;
        self.tagsViewController.view.hidden = YES;
        self.searchViewController.view.hidden = YES;
        self.settingViewController.view.hidden = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self setMenuOffset:0];
    }                completion:^(BOOL finished) {
        self.menuViewBackground.hidden = YES;
    }];
}

#pragma mark - Add or Delete ViewControllers

//todo why we need fix frame here?
- (void)addChildVC:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = CGRectMake(0, 0, self.viewControllerContainerView.bounds.size.width, self.viewControllerContainerView.bounds.size.height);
    [self.viewControllerContainerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)removeChildVC:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller removeFromParentViewController];
    [controller.view removeFromSuperview];
}

#pragma mark - Show or Hide statusbar

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.mainViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.mainViewController;
}

@end
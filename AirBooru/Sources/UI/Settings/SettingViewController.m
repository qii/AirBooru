//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "SettingViewController.h"
#import "MainViewController.h"
#import "ImageHelper.h"
#import "RootViewController.h"

@interface SettingAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation SettingAnimator
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    SettingViewController *fromViewController = (SettingViewController *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MainViewController *toViewController = (MainViewController *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];

    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    [UIView animateWithDuration:0.3 animations:^{
        // Fade in the second view controller's view
        toViewController.view.alpha = 1.0;
        fromViewController.view.alpha = 0.0;
        fromViewController.view.frame = CGRectMake(fromViewController.view.frame.size.width, 0, fromViewController.view.frame.size.width,
                fromViewController.view.frame.size.height);
    }                completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];

        if (![transitionContext transitionWasCancelled]) {
            [fromViewController.view removeFromSuperview];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                // Fade in the second view controller's view
                toViewController.view.alpha = 1.0;
                fromViewController.view.alpha = 1.0;
                fromViewController.view.frame = CGRectMake(0, 0, fromViewController.view.frame.size.width,
                        fromViewController.view.frame.size.height);
            }                completion:^(BOOL finished) {

            }];
        };
    }];
}

@end

@interface SettingViewController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property(strong, nonatomic) UIPercentDrivenInteractiveTransition *interactivePopTransition;
@end

@implementation SettingViewController

+ (SettingViewController *)viewControllerFromStoryBoard {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:NSStringFromClass([SettingViewController class]) bundle:nil];
    SettingViewController *controller = [storyBoard instantiateInitialViewController];
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
//            initWithImage:[ImageHelper scaleImageToSize:[UIImage imageNamed:@"menu_50.png"] size:CGSizeMake(30, 30)] style:UIBarButtonItemStylePlain
//                   target:self action:@selector(showMenuBar:)];
//    self.navigationItem.leftBarButtonItem = menuButton;
//    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    popRecognizer.edges = UIRectEdgeLeft;
//    [self.view addGestureRecognizer:popRecognizer];
}

- (void)showMenuBar:(id)showMenuBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
//    NSLog(@"percent %f", progress);
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Create a interactive transition and pop the view controller
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }

        self.interactivePopTransition = nil;
    }
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a DSLSecondViewController
    if (fromVC == self && [toVC isKindOfClass:[MainViewController class]]) {
        return [[SettingAnimator alloc] init];
    }
    else {
        return nil;
    }
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    // Check if this is for our custom transition
    if ([animationController isKindOfClass:[SettingAnimator class]]) {
        return self.interactivePopTransition;
    }
    else {
        return nil;
    }
}

@end
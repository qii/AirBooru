//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "RootTabNavigationController.h"
#import "UIBarButtonItem+Category.h"

@interface RootTabNavigationController ()

@end

@implementation RootTabNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self
                                                                                   action:@selector(back)
                                                                                    image:@"navigationbar_back_withtext"
                                                                                highImage:@"navigationbar_back_withtext_highlighted"
                                                                                    title:self.title];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back {
    [self popViewControllerAnimated:YES];
}
@end
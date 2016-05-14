//
// Created by qii on 7/10/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ThemeHelper.h"

#define kColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]


@implementation ThemeHelper

+ (void)styleApp {
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
            setTintColor:[ThemeHelper tintColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], [UIPopoverController class], nil]
            setTintColor:[ThemeHelper tintColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil]
            setTintColor:[ThemeHelper tintColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], [UIPopoverController class], nil]
            setTintColor:[ThemeHelper tintColor]];
    [[UISwitch appearanceWhenContainedIn:nil]
            setOnTintColor:[ThemeHelper tintColor]];
}

+ (UIColor *)tintColor {
    return kColor(45, 50, 98);
}

+ (UIColor *)settingBackgroundColor {
    return kColor(235, 235, 241);
}

+ (UIColor *)settingCellLineColor {
    return kColor(188, 186, 193);
}

+ (UIColor *)settingCellHighLightedColor {
    return kColor(208, 208, 208);
}

//
// Fix background color bug
// This patch can be applied once in viewDidLoad if you use UITableViewController
// http://stackoverflow.com/q/23026531/351305
//
+ (void)fixSearchBarHeaderViewBackgroundColorBug:(UITableView *)tableView {
    // First subview in UITableView is a stub view positioned between table's top edge and table's header view.
    UIView *stubView = [tableView.subviews firstObject];

    // Make sure it's stub view and not anything else
    if ([NSStringFromClass([stubView class]) isEqualToString:@"UIView"]) {
        // Set its alpha to zero to use background color from UITableView
        stubView.alpha = 0.0f;
    }
}

@end
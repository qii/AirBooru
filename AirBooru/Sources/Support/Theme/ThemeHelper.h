//
// Created by qii on 7/10/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface ThemeHelper : NSObject

+ (void)styleApp;

+ (UIColor *)tintColor;

+ (UIColor *)settingBackgroundColor;

+ (UIColor *)settingCellLineColor;

+ (UIColor *)settingCellHighLightedColor;

+ (void)fixSearchBarHeaderViewBackgroundColorBug:(UITableView *)tableView;
@end
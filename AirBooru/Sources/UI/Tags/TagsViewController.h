//
// Created by qii on 5/17/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"


@interface TagsViewController : UIViewController
@property(nonatomic, strong) IBOutlet UITableView *tableView;

+ (UINavigationController *)viewControllerFromStoryboard;
@end
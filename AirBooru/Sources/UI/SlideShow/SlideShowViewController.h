//
// Created by qii on 6/3/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class PostList;


typedef void (^SlideShowViewControllerSwitchBlock)(int index);

typedef void (^SlideShowViewControllerDismissBlock)();

@interface SlideShowViewController : UIViewController
@property(copy, nonatomic) SlideShowViewControllerSwitchBlock switchBlock;
@property(copy, nonatomic) SlideShowViewControllerDismissBlock dismissBlock;
@property(strong, nonatomic) PostList *sources;
@property(assign, nonatomic) int startIndex;
@end
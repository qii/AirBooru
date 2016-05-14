//
//  MainViewController.h
//  AirBooru
//
//  Created by qii on 4/24/15.
//  Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PostListViewController.h"

typedef NS_ENUM(NSInteger, HomeListCategory) {
    Latest,
    Score,
    Random,
    PopularByDay,
    PopularByWeek,
    PopularByMonth
};

@interface MainViewController : PostListViewController

@end

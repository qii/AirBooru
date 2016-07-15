//
// Created by qii on 2/6/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"


@class ViewPager;

@protocol ViewPagerDelegate <NSObject>
- (int)numberOfViewsInViewPager:(ViewPager *)viewPager;

- (UIView *)viewPager:(ViewPager *)viewPager viewForIndex:(int)index size:(CGSize)size;

- (void)viewPager:(ViewPager *)viewPager selectItem:(int)index currentView:(UIView *)view;

- (void)viewPager:(ViewPager *)viewPager destroyItem:(UIView *)item;
@end

@interface ViewPager : UIView
@property(weak, nonatomic) id <ViewPagerDelegate> delegate;

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (int)currentItem;

- (UIView *)currentItemView;

@end
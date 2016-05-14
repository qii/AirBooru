//
// Created by qii on 2/6/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import "ViewPager.h"
#import "ViewPagerItem.h"
#import "CSScrollView.h"

@interface ViewPager () <UIScrollViewDelegate>
@property(strong, nonatomic) UIScrollView *pagingScrollView;
@property(assign, nonatomic) int currentPageIndex;
@property(strong, nonatomic) NSMutableSet *visiblePages;
@property(strong, nonatomic) NSMutableSet *recycledPages;
@end

@implementation ViewPager

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initView];
    return self;
}

- (void)initView {
    self.visiblePages = [[NSMutableSet alloc] init];
    self.recycledPages = [[NSMutableSet alloc] init];

    CGRect size = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.pagingScrollView = [[CSScrollView alloc] initWithFrame:size];
    self.pagingScrollView.pagingEnabled = YES;
    self.pagingScrollView.delegate = self;
    self.pagingScrollView.showsHorizontalScrollIndicator = NO;
    self.pagingScrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.pagingScrollView];
}

- (void)dealloc {
    [self clean];
}

- (void)clean {
    for (ViewPagerItem *page in self.visiblePages) {
        UIView *containerView = page.view;
        UIView *contentView = containerView.subviews.firstObject;
        [contentView removeFromSuperview];
        [containerView removeFromSuperview];
        [self.delegate viewPager:self destroyItem:contentView];
    }
    [self.visiblePages removeAllObjects];

    for (ViewPagerItem *page in self.recycledPages) {
        UIView *containerView = page.view;
        UIView *contentView = containerView.subviews.firstObject;
        [contentView removeFromSuperview];
        [containerView removeFromSuperview];
        [self.delegate viewPager:self destroyItem:contentView];
    }
    [self.recycledPages removeAllObjects];
}

- (void)setDelegate:(id <ViewPagerDelegate>)delegate {
    if (_delegate != nil) {
        [self clean];
    }
    _delegate = delegate;

    int count = [self.delegate numberOfViewsInViewPager:self];
    CGRect size = self.pagingScrollView.bounds;
    CGSize result = CGSizeMake(size.size.width * count, size.size.height);
    self.pagingScrollView.contentSize = result;
    [self scrollViewDidScroll:self.pagingScrollView];
}

- (int)count {
    if (self.delegate != nil) {
        return [self.delegate numberOfViewsInViewPager:self];
    } else {
        return 0;
    }
}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (index < [self count]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [self.pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x, 0) animated:animated];
        [self setItemSelected:index];
    }
}

- (int)currentItem {
    return self.currentPageIndex;
}

- (UIView *)currentItemView {
    UIView *currentView = nil;
    for (ViewPagerItem *item in self.visiblePages) {
        if (item.index == self.currentPageIndex) {
            currentView = item.view;
            break;
        }
    }
    return currentView;
}

- (void)backToPageLocation {
    int currentItem = self.currentPageIndex;
    CGRect normalRect = [self frameForPageAtIndex:currentItem];
    CGPoint currentOffset = self.pagingScrollView.contentOffset;
    float itemA1 = normalRect.origin.x - normalRect.size.width * 1 / 3;
//    float itemA2 = normalRect.origin.x;
//    float itemA3 = normalRect.origin.x + normalRect.size.width / 2;
//    float itemA4 = normalRect.origin.x + normalRect.size.width;
    float itemA5 = normalRect.origin.x + normalRect.size.width * 1 / 3;

    float offset = currentOffset.x;

    if (offset <= itemA1) {
        [self jumpToPageAtIndex:currentItem - 1 animated:YES];
    } else if (itemA1 < offset && offset < itemA5) {
        [self jumpToPageAtIndex:currentItem animated:YES];
    } else {
        [self jumpToPageAtIndex:(currentItem + 1) animated:YES];
    }

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (void)setItemSelected:(int)index {
    if (self.delegate) {
        UIView *currentView = nil;
        for (ViewPagerItem *item in self.visiblePages) {
            if (item.index == index) {
                currentView = item.view;
                break;
            }
        }
        [self.delegate viewPager:self selectItem:index currentView:currentView.subviews.firstObject];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate == nil) {
        return;
    }

    // Tile pages
    [self tilePages];

    // Calculate current page
    CGRect visibleBounds = self.pagingScrollView.bounds;
    NSInteger index = (NSInteger) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) {
        index = 0;
    }
    if (index > [self.delegate numberOfViewsInViewPager:self] - 1) {
        index = [self.delegate numberOfViewsInViewPager:self] - 1;
    }
    int previousCurrentPage = self.currentPageIndex;
    self.currentPageIndex = index;
    if (self.currentPageIndex != previousCurrentPage) {
//        [self didStartViewingPageAtIndex:index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"ViewPager scrollViewDidEndDecelerating");
    [self setItemSelected:self.currentPageIndex];
}

#pragma mark - Paging

- (void)tilePages {
    CGRect visibleBounds = self.pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger) floorf((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex = (NSInteger) floorf((CGRectGetMaxX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) {
        iFirstIndex = 0;
    }
    if (iFirstIndex > [self count] - 1) {
        iFirstIndex = [self count] - 1;
    }
    if (iLastIndex < 0) {
        iLastIndex = 0;
    }
    if (iLastIndex > [self count] - 1) {
        iLastIndex = [self count] - 1;
    }

    int remainPageCount = 1;

    iFirstIndex = MAX(0, iFirstIndex - remainPageCount);
    iLastIndex = MIN([self count], iLastIndex + remainPageCount);

    // Recycle no longer needed pages
    NSInteger pageIndex;
    NSMutableSet *removedPages = [[NSMutableSet alloc] init];
    for (ViewPagerItem *page in self.visiblePages) {
        pageIndex = page.index;
        if (pageIndex < (NSUInteger) iFirstIndex || pageIndex > (NSUInteger) iLastIndex) {
            UIView *containerView = page.view;
            UIView *contentView = containerView.subviews.firstObject;
            [contentView removeFromSuperview];
            [containerView removeFromSuperview];
            [self.delegate viewPager:self destroyItem:contentView];
            [removedPages addObject:page];
            NSLog(@"Removed page at index %lu", (unsigned long) pageIndex);
        }
    }

    [self.visiblePages minusSet:removedPages];

    // Add missing pages
    for (NSUInteger index = (NSUInteger) iFirstIndex; index < (NSUInteger) iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            // Add new page
            ViewPagerItem *page = [[ViewPagerItem alloc] init];
            CGSize singlePageSize = self.pagingScrollView.bounds.size;
            UIView *contentView = [self.delegate viewPager:self viewForIndex:index size:singlePageSize];
            UIView *containerView = [[UIView alloc] init];
            containerView.clipsToBounds = YES;
            contentView.frame = CGRectMake(0, 0, singlePageSize.width, singlePageSize.height);
            [containerView addSubview:contentView];

            page.view = containerView;
            page.index = index;
            [self.visiblePages addObject:page];

            [self configurePage:page forIndex:index];

            [self.pagingScrollView addSubview:page.view];
            NSLog(@"Added page at index %lu", (unsigned long) index);
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (ViewPagerItem *page in self.visiblePages)
        if (page.index == index) return YES;
    return NO;
}

- (void)configurePage:(ViewPagerItem *)page forIndex:(NSUInteger)index {
    page.view.frame = [self frameForPageAtIndex:index];
    page.index = index;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = self.pagingScrollView.bounds;
    CGRect pageFrame = bounds;
//    pageFrame.origin.y=0;
//    self.pagingScrollView.bounds=CGRectIntegral(pageFrame);
    pageFrame.origin.x = (bounds.size.width * index);
//    pageFrame.size.height-=80;
    return CGRectIntegral(pageFrame);
}
@end
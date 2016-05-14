//
// Created by qii on 7/23/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "FixUIRefreshUITableView.h"

@implementation FixUIRefreshUITableView
- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (self.tracking) {
        CGFloat diff = contentInset.top - self.contentInset.top;
        CGPoint translation = [self.panGestureRecognizer translationInView:self];
        translation.y -= diff * 3.0 / 2.0;
        [self.panGestureRecognizer setTranslation:translation inView:self];
    }
    [super setContentInset:contentInset];
}
@end
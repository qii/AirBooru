//
// Created by qii on 5/8/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import "FixUIRefreshUICollectionView.h"

@implementation FixUIRefreshUICollectionView
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
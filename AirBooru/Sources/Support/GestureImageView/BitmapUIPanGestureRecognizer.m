//
// Created by qii on 7/15/16.
// Copyright (c) 2016 org.qii.airbooru. All rights reserved.
//

#import "BitmapUIPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface BitmapUIPanGestureRecognizer ()

@end

@implementation BitmapUIPanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];

    CGRect rect = CGRectApplyAffineTransform(self.rect, self.layer.affineTransform);
    CGPoint nowPoint = [aTouch locationInView:self.view];
    CGPoint previousPoint = [aTouch previousLocationInView:self.view];

    if (nowPoint.x > previousPoint.x && rect.origin.x == 0) {
        self.state = UIGestureRecognizerStateFailed;
    } else if (nowPoint.x < previousPoint.x && ABS(rect.origin.x + rect.size.width - self.view.frame.size.width) < 0.0001) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

@end
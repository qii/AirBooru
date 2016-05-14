//
// Created by qii on 6/10/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef void (^FlipAnimatorExitCompletionBlock)();


@interface FlipAnimator : NSObject

+ (instancetype)animator:(CALayer *)layer bounds:(CGRect)bounds baseMatrix:(CATransform3D)baseMatrix enter:(BOOL)enter exitCompletionBlock:(FlipAnimatorExitCompletionBlock)exitCompletionBlock;

- (void)start;

@end
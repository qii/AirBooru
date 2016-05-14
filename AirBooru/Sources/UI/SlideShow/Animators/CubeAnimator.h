//
// Created by qii on 6/10/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef void (^AnimatorExitCompletionBlock)();

@interface CubeAnimator : NSObject

+ (instancetype)animator:(CALayer *)layer bounds:(CGRect)bounds baseMatrix:(CATransform3D)baseMatrix enter:(BOOL)enter exitCompletionBlock:(AnimatorExitCompletionBlock)exitCompletionBlock;

- (void)start;
@end
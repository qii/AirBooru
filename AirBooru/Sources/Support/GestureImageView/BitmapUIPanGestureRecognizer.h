//
// Created by qii on 7/15/16.
// Copyright (c) 2016 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"


@interface BitmapUIPanGestureRecognizer : UIPanGestureRecognizer
@property(weak, nonatomic) CALayer *layer;
@property(assign, nonatomic) CGRect rect;
//+ (instancetype)recognizerWith:(CALayer *)layer rect:(CGRect)rect;
@end
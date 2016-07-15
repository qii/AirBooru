//
//  TransformUtility.h
//  BitmapView
//
//  Created by qii on 7/12/16.
//  Copyright © 2016 qii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TransformUtility : NSObject
+ (CGFloat)xScale:(CGAffineTransform)transform;

+ (CGFloat)yScale:(CGAffineTransform)transform;

+ (CGFloat)rotation:(CGAffineTransform)transform;

+ (CGFloat)tx:(CGAffineTransform)transform;

+ (CGFloat)ty:(CGAffineTransform)transform;

+ (CGFloat)radian2Degree:(CGFloat)radian;

+ (CGFloat)degree2Radian:(CGFloat)degree;

+ (CGAffineTransform)rotate:(float)rotateByValue
                     pivotX:(float)pivotX
                     pivotY:(float)pivotY;

+ (CGAffineTransform)scale:(float)scaleValue
                    pivotX:(float)pivotX
                    pivotY:(float)pivotY;

+ (CGAffineTransform)same:(CGAffineTransform)transform;
@end

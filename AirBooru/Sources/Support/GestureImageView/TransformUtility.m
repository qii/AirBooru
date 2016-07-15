//
//  TransformUtility.m
//  BitmapView
//
//  Created by qii on 7/12/16.
//  Copyright © 2016 qii. All rights reserved.
//

#import "TransformUtility.h"

@implementation TransformUtility

+ (CGFloat)xScale:(CGAffineTransform)transform {
    CGAffineTransform t = transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

+ (CGFloat)yScale:(CGAffineTransform)transform {
    CGAffineTransform t = transform;
    return sqrt(t.b * t.b + t.d * t.d);
}

+ (CGFloat)rotation:(CGAffineTransform)transform {
    CGAffineTransform t = transform;
    return atan2f(t.b, t.a);
}

+ (CGFloat)tx:(CGAffineTransform)transform {
    CGAffineTransform t = transform;
    return t.tx;
}

+ (CGFloat)ty:(CGAffineTransform)transform {
    CGAffineTransform t = transform;
    return t.ty;
}

+ (CGFloat)radian2Degree:(CGFloat)radian {
    return ((radian) * (180.0 / M_PI));
}

+ (CGFloat)degree2Radian:(CGFloat)degree {
    return degree / 180.0 * M_PI;
}

+ (CGAffineTransform)rotate:(float)rotateByValue
                     pivotX:(float)pivotX
                     pivotY:(float)pivotY {
    //  CGAffineTransform rotateTransform =
    //      CGAffineTransformMakeRotation(rotateByValue);
    //
    //  CGAffineTransform all = CGAffineTransformIdentity;
    //
    //  CGAffineTransform a = CGAffineTransformMakeTranslation(-pivotX, -pivotY);
    //  all = CGAffineTransformConcat(all, a);
    //  all = CGAffineTransformConcat(all, rotateTransform);
    //
    //  CGAffineTransform b = CGAffineTransformMakeTranslation(pivotX, pivotY);
    //  all = CGAffineTransformConcat(all, b);

    //比上面简短
    const CGFloat fx = pivotX, fy = pivotY, fcos = cos(rotateByValue),
            fsin = sin(rotateByValue);
    CGAffineTransform all =
            CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin,
                    fy - fx * fsin - fy * fcos);
    return all;
}

+ (CGAffineTransform)scale:(float)scaleValue
                    pivotX:(float)pivotX
                    pivotY:(float)pivotY {
    CGAffineTransform scaleTransform =
            CGAffineTransformMakeScale(scaleValue, scaleValue);

    CGAffineTransform all = CGAffineTransformIdentity;

    CGAffineTransform a = CGAffineTransformMakeTranslation(-pivotX, -pivotY);
    all = CGAffineTransformConcat(all, a);
    all = CGAffineTransformConcat(all, scaleTransform);

    CGAffineTransform b = CGAffineTransformMakeTranslation(pivotX, pivotY);
    all = CGAffineTransformConcat(all, b);
    return all;
}

+ (CGAffineTransform)same:(CGAffineTransform)transform {
    return CGAffineTransformMake(transform.a, transform.b, transform.c,
            transform.d, transform.tx, transform.ty);
}
@end

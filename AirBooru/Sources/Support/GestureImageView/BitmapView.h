//
//  BitmapView.h
//  BitmapView
//
//  Created by qii on 7/11/16.
//  Copyright © 2016 qii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BitmapView : UIView
@property(strong, nonatomic) CALayer *imageLayer;

@property(strong, nonatomic) UIImage *image;

@property(assign, nonatomic) CGAffineTransform baseImageTransform;

@property(assign, nonatomic) CGAffineTransform baseFitCenterImageTransform;
@property(assign, nonatomic) CGAffineTransform baseFullCenterImageTransform;
@property(assign, nonatomic) CGAffineTransform baseCropCenterImageTransform;

- (instancetype)initWithFrame:(CGRect)frame;

- (CGAffineTransform)getDrawTransform;

- (void)translate:(float)deltaX deltaY:(float)deltaY;

- (void)scale:(float)scaleValue pivotX:(float)pivotX pivotY:(float)pivotY;

- (void)rotate:(float)rotateByValue pivotX:(float)pivotX pivotY:(float)pivotY;

- (float)getImageWidth;

- (float)getImageHeight;

- (void)updateCurrentDrawTransform:(CGAffineTransform)form
                           animate:(BOOL)animate;

- (float)getImageLayerTop;

- (float)getImageLayerLeft;

- (float)getMinScale;

- (float)getMaxScale;

- (CGAffineTransform)getMinTransform;

- (CGAffineTransform)getNextTransform;
@end

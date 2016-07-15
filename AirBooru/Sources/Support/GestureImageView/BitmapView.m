//
//  BitmapView.m
//  BitmapView
//
//  Created by qii on 7/11/16.
//  Copyright © 2016 qii. All rights reserved.
//

#import "BitmapView.h"
#import "TransformUtility.h"

@interface BitmapView ()

@property(assign, nonatomic) CGAffineTransform imageTransform;
@end

@implementation BitmapView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
//
//+ (Class)layerClass {
//    return [CATiledLayer class];
//}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    //之所以一定要用个CALayer而不是直接用自己的layer的原因是，你改了自己layer的Matrix，会导致self.frame.origin.x和y也会变，这样算起来好麻烦
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    self.imageTransform = CGAffineTransformIdentity;

    self.imageLayer = [[CALayer alloc] init];
    self.imageLayer.allowsEdgeAntialiasing = YES;
    self.imageLayer.affineTransform = self.imageTransform;
    self.imageLayer.anchorPoint = CGPointMake(0, 0);
    [self.layer addSublayer:self.imageLayer];

    return self;
}

- (CGAffineTransform)getDrawTransform {
    return self.imageTransform;
}

- (void)translate:(float)deltaX deltaY:(float)deltaY {
    CGAffineTransform translationTransform =
            CGAffineTransformMakeTranslation(deltaX, deltaY);
    self.imageTransform =
            CGAffineTransformConcat(self.imageTransform, translationTransform);

    [self updateCurrentDrawTransform:self.imageTransform animate:NO];
}

- (void)scale:(float)scaleValue pivotX:(float)pivotX pivotY:(float)pivotY {
    CGAffineTransform all =
            [TransformUtility scale:scaleValue pivotX:pivotX pivotY:pivotY];
    self.imageTransform = CGAffineTransformConcat(self.imageTransform, all);
    [self updateCurrentDrawTransform:self.imageTransform animate:NO];
}

- (void)rotate:(float)rotateByValue pivotX:(float)pivotX pivotY:(float)pivotY {
    CGAffineTransform all =
            [TransformUtility rotate:rotateByValue pivotX:pivotX pivotY:pivotY];
    self.imageTransform = CGAffineTransformConcat(self.imageTransform, all);
    [self updateCurrentDrawTransform:self.imageTransform animate:NO];
}

- (void)calcuteImageBaseTransform {
    int imageWidth = [self getImageWidth];
    int imageHeight = [self getImageHeight];

    int viewWidth = self.frame.size.width;
    int viewHeight = self.frame.size.height;

    {
        float scale = MIN((float) viewWidth / (float) imageWidth,
                (float) viewHeight / (float) imageHeight);

        CGAffineTransform scaleTransform = [TransformUtility scale:scale
                                                            pivotX:imageWidth / 2
                                                            pivotY:imageHeight / 2];
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(
                (viewWidth - imageWidth) / 2, (viewHeight - imageHeight) / 2);

        self.baseFitCenterImageTransform =
                CGAffineTransformConcat(scaleTransform, translateTransform);
    }
    {
        float scale = MAX((float) viewWidth / (float) imageWidth,
                (float) viewHeight / (float) imageHeight);

        CGAffineTransform scaleTransform = [TransformUtility scale:scale
                                                            pivotX:imageWidth / 2
                                                            pivotY:imageHeight / 2];
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(
                (viewWidth - imageWidth) / 2, (viewHeight - imageHeight) / 2);

        self.baseCropCenterImageTransform =
                CGAffineTransformConcat(scaleTransform, translateTransform);
    }

    {
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(
                (viewWidth - imageWidth) / 2, (viewHeight - imageHeight) / 2);

        self.baseFullCenterImageTransform = translateTransform;
    }

    self.baseImageTransform = self.baseFitCenterImageTransform;
}

- (void)setImage:(UIImage *)image {
    if (_image) {
        //todo 我也搞不懂为什么要重置,不然各种问题,跟真正显示的完全不一样
        [self updateCurrentDrawTransform:CGAffineTransformIdentity animate:NO];
        self.imageLayer.contents = nil;
    }
    _image = image;
    if (_image) {
        self.imageLayer.contents = (__bridge id _Nullable) (_image.CGImage);
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.imageLayer.frame =
                CGRectMake(0, 0, _image.size.width, _image.size.height);
        [CATransaction commit];

        [self calcuteImageBaseTransform];
        [self updateCurrentDrawTransform:self.baseImageTransform animate:NO];
        //  [self setNeedsDisplay];
    }
}

- (float)getImageWidth {
    return _image.size.width;
}

- (float)getImageHeight {
    return _image.size.height;
}

- (void)updateCurrentDrawTransform:(CGAffineTransform)form
                           animate:(BOOL)animate {
    self.imageTransform = form;

    [CATransaction begin];
    if (!animate) {
        [CATransaction setDisableActions:YES];
    } else {
        [CATransaction setAnimationDuration:0.3f];
    }
    self.imageLayer.affineTransform = self.imageTransform;
    [CATransaction commit];
}

- (float)getImageLayerTop {
    return self.imageLayer.frame.origin.y;
}

- (float)getImageLayerLeft {
    return self.imageLayer.frame.origin.x;
}

- (float)getMinScale {
    float scale = [TransformUtility xScale:self.baseFitCenterImageTransform];
    scale =
            MIN(scale, [TransformUtility xScale:self.baseFullCenterImageTransform]);
    scale =
            MIN(scale, [TransformUtility xScale:self.baseCropCenterImageTransform]);
    return scale * 0.3f;
}

- (float)getMaxScale {
    float scale = [TransformUtility xScale:self.baseFitCenterImageTransform];
    scale =
            MAX(scale, [TransformUtility xScale:self.baseFullCenterImageTransform]);
    scale =
            MAX(scale, [TransformUtility xScale:self.baseCropCenterImageTransform]);
    return scale * 5.0f;
}

- (CGAffineTransform)getMinTransform {
    float fitCenterScale =
            [TransformUtility xScale:self.baseFitCenterImageTransform];
    float fullCenterScale =
            [TransformUtility xScale:self.baseFullCenterImageTransform];
    float cropCenterScale =
            [TransformUtility xScale:self.baseCropCenterImageTransform];

    float scale = MIN(fitCenterScale, MIN(fullCenterScale, cropCenterScale));
    if (scale == fitCenterScale) {
        return self.baseFitCenterImageTransform;
    } else if (scale == fullCenterScale) {
        return self.baseFullCenterImageTransform;
    } else {
        return self.baseCropCenterImageTransform;
    }
}

- (CGAffineTransform)getNextTransform {
    if (CGAffineTransformEqualToTransform(self.baseImageTransform,
            self.baseFitCenterImageTransform)) {
        return self.baseCropCenterImageTransform;
    } else if (CGAffineTransformEqualToTransform(
            self.baseImageTransform, self.baseCropCenterImageTransform)) {
        return self.baseFullCenterImageTransform;
    } else {
        return self.baseFitCenterImageTransform;
    }
}

//- (void)drawRect:(CGRect)rect {
//  CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
//  if (_image) {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    CGContextConcatCTM(context, self.imageTransform);
//
//    // Scale the context so that the image is rendered
//    // at the correct size for the zoom level.
//    //        CGContextScaleCTM(context, 1.0f ,1.0f );
//    //        CGContextDrawImage(context, rect , _image .CGImage );
//    [_image drawInRect:rect];
//    CGContextRestoreGState(context);
//  }
//}

@end

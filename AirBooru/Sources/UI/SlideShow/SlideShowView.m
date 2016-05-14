//
// Created by qii on 6/3/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import "UIView+BlocksKit.h"
#import "SlideShowView.h"
#import "CubeAnimator.h"
#import "FlipAnimator.h"
#import "ViewPager.h"

static const int kAnimationDurationSeconds = 1;
static const int kViewPagerPageSpace = 5;

static inline double radians(double degrees) {
    return degrees * M_PI / 180;
}

@interface SlideShowView ()
@property(strong, nonatomic) CALayer *exitLayer;
@property(strong, nonatomic) CALayer *enterLayer;

@property(strong, nonatomic) CATransformLayer *containerLayer;

@property(assign, nonatomic) CATransform3D exitLayerTransform;
@property(assign, nonatomic) CATransform3D enterLayerTransform;
@end

@implementation SlideShowView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.containerLayer = [CATransformLayer layer];
        self.containerLayer.frame = self.bounds;
        [self.layer addSublayer:self.containerLayer];
    }

    return self;
}

- (void)setExitImage:(UIImage *)exitImage {
    _exitImage = exitImage;

    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];

    if (self.exitLayer == nil) {
        self.exitLayer = [CALayer layer];
        self.exitLayer.backgroundColor = [UIColor greenColor].CGColor;
        self.exitLayer.allowsEdgeAntialiasing = YES;
        [self.containerLayer addSublayer:self.exitLayer];
    }

    self.exitLayer.opacity = 1.0f;
    self.exitLayer.contents = nil;
    self.exitLayer.contents = (id) _exitImage.CGImage;
    self.exitLayer.contentsScale = _exitImage.scale;
    self.exitLayer.anchorPoint = CGPointMake(0.5, 0.5);
    self.exitLayer.transform = CATransform3DIdentity;
    self.exitLayer.frame = CGRectMake(0, 0, _exitImage.size.width, _exitImage.size.height);
    self.exitLayerTransform = CATransform3DIdentity;
    self.exitLayerTransform = [self calcBaseTransform:_exitImage];
    self.exitLayer.transform = self.exitLayerTransform;
    [CATransaction commit];
}

- (void)setEnterImage:(UIImage *)enterImage {
    _enterImage = enterImage;

    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];

    CALayer *previousEnterLayer = self.enterLayer;
    if (previousEnterLayer != nil) {
        [previousEnterLayer removeFromSuperlayer];
    }

    self.enterLayer = [CALayer layer];
    self.enterLayer.backgroundColor = [UIColor blueColor].CGColor;
    self.enterLayer.allowsEdgeAntialiasing = YES;
//    [self.containerLayer addSublayer:self.enterLayer];
    [self.containerLayer insertSublayer:self.enterLayer below:self.exitLayer];
    self.enterLayer.opacity = 0.0f;
    self.enterLayer.contents = (id) self.enterImage.CGImage;
    self.enterLayer.contentsScale = self.enterImage.scale;
    self.enterLayer.anchorPoint = CGPointMake(0.5, 0.5);
    self.enterLayer.transform = CATransform3DIdentity;
    self.enterLayer.frame = CGRectMake(0, 0, self.enterImage.size.width, self.enterImage.size.height);
    self.enterLayerTransform = [self calcBaseTransform:_enterImage];
    self.enterLayer.transform = self.enterLayerTransform;
    [CATransaction commit];
}

- (void)animateCube:(BOOL)enter layer:(CALayer *)layer baseMatrix:(CATransform3D)baseMatrix {
    CubeAnimator *animator = [CubeAnimator animator:layer bounds:self.bounds baseMatrix:baseMatrix enter:enter exitCompletionBlock:^{
        if (self.completionBlock != nil) {
            self.completionBlock(self.exitIndex);
        }
    }];
    [animator start];
}

- (void)animateFlip:(BOOL)enter layer:(CALayer *)layer baseMatrix:(CATransform3D)baseMatrix {
    FlipAnimator *animator = [FlipAnimator animator:layer bounds:self.bounds baseMatrix:baseMatrix enter:enter exitCompletionBlock:^{
        if (self.completionBlock != nil) {
            self.completionBlock(self.exitIndex);
        }
    }];
    [animator start];
}

- (void)animateFade:(BOOL)enter layer:(CALayer *)layer baseMatrix:(CATransform3D)baseMatrix {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (!enter) {
            if (self.completionBlock != nil) {
                self.completionBlock(self.exitIndex);
            }
        }
    }];
    [CATransaction setAnimationDuration:kAnimationDurationSeconds];
    if (enter) {
        layer.opacity = 1.0f;
    } else {
        layer.opacity = 0.0f;
    }
    [CATransaction commit];
}

- (void)animateSlide:(BOOL)enter layer:(CALayer *)layer baseMatrix:(CATransform3D)baseMatrix {
    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];
    layer.opacity = 1.0;
    CGRect frame = layer.frame;
    if (enter) {
        frame.origin.x = CGRectGetWidth(frame) + kViewPagerPageSpace * 2;
    } else {
        frame.origin.x = 0;
    }
    layer.frame = frame;
    [CATransaction commit];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (!enter) {
            if (self.completionBlock != nil) {
                self.completionBlock(self.exitIndex);
            }
        }
    }];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setAnimationDuration:kAnimationDurationSeconds];
    frame = layer.frame;
    if (enter) {
        frame.origin.x = 0;
    } else {
        frame.origin.x = -CGRectGetWidth(frame) - kViewPagerPageSpace * 2;
    }
    layer.frame = frame;
    [CATransaction commit];
}

- (void)animateCard:(BOOL)enter layer:(CALayer *)layer baseMatrix:(CATransform3D)baseMatrix {
    {
        [CATransaction begin];
        [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];

        CATransform3D layerOneBaseTransform = CATransform3DIdentity;
        float from = enter ? 0.5f : 1;
        float scale = from;
        layerOneBaseTransform = CATransform3DConcat(baseMatrix, layerOneBaseTransform);
        layerOneBaseTransform = CATransform3DScale(layerOneBaseTransform, scale, scale, 1.0f);
        layer.opacity = scale;
        layer.transform = layerOneBaseTransform;

        [CATransaction commit];
    }

    {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (!enter) {
                if (self.completionBlock != nil) {
                    self.completionBlock(self.exitIndex);
                }
            }
        }];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [CATransaction setAnimationDuration:kAnimationDurationSeconds];
        CATransform3D layerOneBaseTransform = CATransform3DIdentity;

        float to = enter ? 1 : 0.5f;
        float scale = to;
        layerOneBaseTransform = CATransform3DConcat(baseMatrix, layerOneBaseTransform);
        layerOneBaseTransform = CATransform3DScale(layerOneBaseTransform, scale, scale, 1.0f);
        layer.opacity = scale;
        layer.transform = layerOneBaseTransform;

        [CATransaction commit];
    }
}

- (CATransform3D)calcBaseTransform:(UIImage *)image {
    CATransform3D matrix = CATransform3DIdentity;
    CGRect layerRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGRect selfRect = self.bounds;
    float layerCenterX = layerRect.origin.x + layerRect.size.width / 2;
    float layerCenterY = layerRect.origin.y + layerRect.size.height / 2;
    float selfCenterX = selfRect.origin.x + selfRect.size.width / 2;
    float selfCenterY = selfRect.origin.y + selfRect.size.height / 2;
    float deltaXCenter = selfCenterX - layerCenterX;
    float deltaYCenter = selfCenterY - layerCenterY;

    matrix = CATransform3DConcat(matrix, CATransform3DMakeTranslation(deltaXCenter, deltaYCenter, 0));

    CGSize imageSize = image.size;
    CGSize viewSize = self.frame.size;

    float widthPercent = viewSize.width / imageSize.width;
    float heightPercent = viewSize.height / imageSize.height;
    float percent = MIN(widthPercent, heightPercent);

    matrix = CATransform3DScale(matrix, percent, percent, 1);
    return matrix;
}

- (CGFloat)calcXScale:(CATransform3D)fullTransform {
    CGAffineTransform t = CGAffineTransformMake(fullTransform.m11, fullTransform.m12, fullTransform.m21, fullTransform.m22, fullTransform.m41, fullTransform.m42);
    return sqrt(t.a * t.a + t.c * t.c);
}

- (CGFloat)calcXTranslate:(CATransform3D)fullTransform {
    CGAffineTransform t = CGAffineTransformMake(fullTransform.m11, fullTransform.m12, fullTransform.m21, fullTransform.m22, fullTransform.m41, fullTransform.m42);
    return t.tx;
}

- (CGFloat)calcYTranslate:(CATransform3D)fullTransform {
    CGAffineTransform t = CGAffineTransformMake(fullTransform.m11, fullTransform.m12, fullTransform.m21, fullTransform.m22, fullTransform.m41, fullTransform.m42);
    return t.ty;
}

- (void)start {
    int value = arc4random_uniform(5);
//    value = 1;
    if (value == 0) {
        [self animateCube:NO layer:self.exitLayer baseMatrix:self.exitLayerTransform];
        [self animateCube:YES layer:self.enterLayer baseMatrix:self.enterLayerTransform];
    } else if (value == 1) {
        [self animateSlide:NO layer:self.exitLayer baseMatrix:self.exitLayerTransform];
        [self animateSlide:YES layer:self.enterLayer baseMatrix:self.enterLayerTransform];
    } else if (value == 2) {
        [self animateFade:NO layer:self.exitLayer baseMatrix:self.exitLayerTransform];
        [self animateFade:YES layer:self.enterLayer baseMatrix:self.enterLayerTransform];
    } else if (value == 3) {
        [self animateFlip:NO layer:self.exitLayer baseMatrix:self.exitLayerTransform];
        [self animateFlip:YES layer:self.enterLayer baseMatrix:self.enterLayerTransform];
    } else if (value == 4) {
        [self animateCard:YES layer:self.enterLayer baseMatrix:self.enterLayerTransform];
        [self animateSlide:NO layer:self.exitLayer baseMatrix:self.exitLayerTransform];
    }
}

- (void)dealloc {
    NSLog(@"SlideShowView dealloc");
}

@end
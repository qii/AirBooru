//
// Created by qii on 6/10/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import "CubeAnimator.h"

static inline double radians(double degrees) {
    return degrees * M_PI / 180;
}

@interface CubeAnimator ()
@property(strong, nonatomic) CALayer *layer;
@property(assign, nonatomic) CATransform3D baseMatrix;
@property(assign, nonatomic) CGRect bounds;
@property(assign, nonatomic) BOOL enter;
@property(copy, nonatomic) AnimatorExitCompletionBlock exitCompletionBlock;

@property(nonatomic, strong) CADisplayLink *timer;
@property(nonatomic, assign) CFTimeInterval duration;
@property(nonatomic, assign) CFTimeInterval timeOffset;
@property(nonatomic, assign) CFTimeInterval lastStep;

@property(nonatomic, assign) float fromValue;
@property(nonatomic, assign) float toValue;
@end

@implementation CubeAnimator

+ (instancetype)animator:(CALayer *)layer bounds:(CGRect)bounds baseMatrix:(CATransform3D)baseMatrix enter:(BOOL)enter exitCompletionBlock:(AnimatorExitCompletionBlock)exitCompletionBlock {
    CubeAnimator *animator = [[CubeAnimator alloc] init];
    animator.layer = layer;
    animator.bounds = bounds;
    animator.baseMatrix = baseMatrix;
    animator.enter = enter;
    animator.exitCompletionBlock = exitCompletionBlock;
    return animator;
}

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)start {
    self.duration = 1.0;
    self.timeOffset = 0.0;
    self.fromValue = self.enter ? 180 : 0;
    self.toValue = self.enter ? 0 : -180;
    self.lastStep = CACurrentMediaTime();
    self.timer = [CADisplayLink displayLinkWithTarget:self
                                             selector:@selector(step:)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop]
                     forMode:NSDefaultRunLoopMode];
}

- (CGFloat)calcXScale:(CATransform3D)fullTransform {
    CGAffineTransform t = CGAffineTransformMake(fullTransform.m11, fullTransform.m12, fullTransform.m21, fullTransform.m22, fullTransform.m41, fullTransform.m42);
    return sqrt(t.a * t.a + t.c * t.c);
}

static float decelerateInterpolator(float t) {
    return (float) (1.0f - (1.0f - t) * (1.0f - t));
}

- (void)step:(NSTimer *)step {
    CFTimeInterval thisStep = CACurrentMediaTime();
    CFTimeInterval stepDuration = thisStep - self.lastStep;
    self.lastStep = thisStep;
    self.timeOffset = MIN(self.timeOffset + stepDuration, self.duration);
    float time = self.timeOffset / self.duration;
    time = decelerateInterpolator(time);

    float degree = self.fromValue + (self.toValue - self.fromValue) * time;

    float radian = radians(degree);
    float sin = sinf(radian);
    float cos = cosf(radian);

    float centerX = CGRectGetMidX(self.bounds);
    float centerY = CGRectGetMidX(self.bounds);

    float deltaX = centerX * sin;
    float deltaZ = centerY * (1 - cos);

    CATransform3D layerOneBaseTransform = CATransform3DIdentity;;

    layerOneBaseTransform.m34 = 1.0f / -500.0f;
    layerOneBaseTransform = CATransform3DConcat(CATransform3DMakeRotation(radian, 0, 1, 0), layerOneBaseTransform);
    layerOneBaseTransform = CATransform3DTranslate(layerOneBaseTransform, deltaX, 0, deltaZ);

    float scale = [self calcXScale:self.baseMatrix];

    layerOneBaseTransform = CATransform3DConcat(layerOneBaseTransform, CATransform3DMakeScale(1.0f / scale, 1.0f / scale, 1.0f));
    layerOneBaseTransform = CATransform3DScale(layerOneBaseTransform, scale, scale, 1.0f);

    layerOneBaseTransform = CATransform3DConcat(layerOneBaseTransform, self.baseMatrix);

    if (self.enter) {
        self.layer.opacity = (time <= 0.25f ? 0 : (time - 0.25f) / 0.75f);
    } else {
        self.layer.opacity = (time >= 0.75f ? 0 : (0.75f - time) / 0.75f);
    }

    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.layer.transform = layerOneBaseTransform;
    [CATransaction commit];

    if (self.timeOffset >= self.duration) {
        [self.timer invalidate];
        self.timer = nil;
        if (!self.enter && self.exitCompletionBlock != nil) {
            self.exitCompletionBlock();
        }
    }
}

@end
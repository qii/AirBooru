//
//  GestureBitmapView.m
//  BitmapView
//
//  Created by qii on 7/11/16.
//  Copyright © 2016 qii. All rights reserved.
//

#import "GestureBitmapView.h"
#import "MatrixAnimator.h"
#import "TransformUtility.h"
#import "BitmapUIPanGestureRecognizer.h"

@interface GestureBitmapView () <UIGestureRecognizerDelegate>
@property(strong, nonatomic) BitmapUIPanGestureRecognizer *bitmapUIPanGestureRecognizer;
@property(assign, nonatomic) CGFloat previousTranslateX;
@property(assign, nonatomic) CGFloat previousTranslateY;

@property(assign, nonatomic) CGFloat previousScale;
@property(assign, nonatomic) CGFloat previousRotation;

@property(assign, nonatomic) CGFloat previousRotationPivotX;
@property(assign, nonatomic) CGFloat previousRotationPivotY;

@property(assign, nonatomic) BOOL switchBaseTransform;
@property(assign, nonatomic) BOOL restoring;

@property(strong, nonatomic) MatrixAnimator *animator;
@end

@implementation GestureBitmapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    BitmapUIPanGestureRecognizer *panRecognizer = [[BitmapUIPanGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(translateGesture:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    self.bitmapUIPanGestureRecognizer = panRecognizer;
    [self addGestureRecognizer:panRecognizer];

    UIPinchGestureRecognizer *pinchGestureRecongnizer = [
            [UIPinchGestureRecognizer alloc] initWithTarget:self
                                                     action:@selector(scaleGesture:)];
    [self addGestureRecognizer:pinchGestureRecongnizer];

    UIRotationGestureRecognizer *rotationGestureRecongnizer =
            [[UIRotationGestureRecognizer alloc]
                    initWithTarget:self
                            action:@selector(rotateGesture:)];
    [self addGestureRecognizer:rotationGestureRecongnizer];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(singleTapGesture:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(doubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];

    [singleTap requireGestureRecognizerToFail:doubleTap];
    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;
    return self;
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    self.bitmapUIPanGestureRecognizer.layer = self.imageLayer;
    self.bitmapUIPanGestureRecognizer.rect = CGRectMake(0, 0, [self getImageWidth], [self getImageHeight]);
}

//fix strange UIScrollView cant scroll issue
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer.view == self) {
        if (CGAffineTransformEqualToTransform(self.baseFitCenterImageTransform, [self getDrawTransform])) {
            //fitCenter直接左右滑动
            return NO;
        }
    }
    return YES;
}

//其他情况交给BitmapUIPanGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[BitmapUIPanGestureRecognizer class]]
            && [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        return YES;
    }
    return NO;
}

#pragma - mark Gesture method

- (void)singleTapGesture:(id)sender {
    NSLog(@"singleTap");
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

- (void)doubleTapGesture:(id)sender {
    NSLog(@"doubleTap");
    if (self.switchBaseTransform || self.restoring) {
        return;
    }
    self.switchBaseTransform = YES;
    CGAffineTransform transform = [self getNextTransform];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self updateCurrentDrawTransform:transform animate:YES];
                         self.baseImageTransform = transform;
                     }
                     completion:^(BOOL finished) {
                         self.switchBaseTransform = NO;
                         NSLog(@"切换BaseMatrix动画结束");
                     }];
}

- (void)translateGesture:(id)sender {
    if (self.switchBaseTransform || self.restoring) {
        return;
    }
    CGPoint translatedPoint =
            [(UIPanGestureRecognizer *) sender translationInView:self];
    int state = [(UIPanGestureRecognizer *) sender state];

    if (state == UIGestureRecognizerStateBegan) {
        // empty
    } else if (state == UIGestureRecognizerStateChanged) {
        [self translate:translatedPoint.x - self.previousTranslateX
                 deltaY:translatedPoint.y - self.previousTranslateY];
    } else if (state == UIGestureRecognizerStateEnded ||
            state == UIGestureRecognizerStateCancelled) {
        [self restore:-1 previousRotatePivotY:-1];
    }
    self.previousTranslateX = translatedPoint.x;
    self.previousTranslateY = translatedPoint.y;
}

- (void)scaleGesture:(id)gesture {
    if (self.switchBaseTransform || self.restoring) {
        return;
    }
    UIPinchGestureRecognizer *pinchGestureRecongnizer =
            (UIPinchGestureRecognizer *) gesture;
    int state = [pinchGestureRecongnizer state];

    if (state == UIGestureRecognizerStateBegan) {
        // empty
        //        lastPoint = [gesture locationInView:[gesture view]];
    } else if (state == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = [TransformUtility xScale:[self getDrawTransform]];

        // Constants to adjust the max/min values of zoom
        //    const CGFloat kMaxScale = 4.0;
        //    const CGFloat kMinScale = 0.3f;

        CGFloat newScale = pinchGestureRecongnizer.scale /
                self.previousScale;  // new scale is in the range (0-1)
        if (currentScale * newScale > [self getMaxScale]) {
            newScale = [self getMaxScale] / currentScale;
        }

        if (currentScale * newScale < [self getMinScale]) {
            newScale = [self getMinScale] / currentScale;
        }

        if (pinchGestureRecongnizer.numberOfTouches >= 2) {
            CGPoint zeroPoint =
                    [pinchGestureRecongnizer locationOfTouch:0 inView:self];
            CGPoint onePoint =
                    [pinchGestureRecongnizer locationOfTouch:1 inView:self];

            float pivotX = (zeroPoint.x + onePoint.x) / 2;
            float pivotY = (zeroPoint.y + onePoint.y) / 2;

            [self scale:newScale pivotX:pivotX pivotY:pivotY];
        }

        //        CGPoint point = [gesture locationInView:[gesture view]];
        //        CGAffineTransform transformTranslate =
        //        CGAffineTransformTranslate([[gesture view] transform],
        //        point.x-lastPoint.x, point.y-lastPoint.y);
        //
        //        [gesture view].transform = transformTranslate;
    } else if (state == UIGestureRecognizerStateEnded ||
            state == UIGestureRecognizerStateCancelled) {
        [self restore:-1 previousRotatePivotY:-1];
    }

    self.previousScale = pinchGestureRecongnizer.scale;
}

- (void)rotateGesture:(id)sender {
    if (self.switchBaseTransform || self.restoring) {
        return;
    }

    int state = [(UIRotationGestureRecognizer *) sender state];

    if (state == UIGestureRecognizerStateBegan) {
        // emtpy
        self.previousRotationPivotX = -1;
        self.previousRotationPivotY = -1;
    } else if (state == UIGestureRecognizerStateChanged) {
        CGFloat rotation = ([(UIRotationGestureRecognizer *) sender rotation] -
                self.previousRotation);
        if (((UIRotationGestureRecognizer *) sender).numberOfTouches >= 2) {
            CGPoint zeroPoint =
                    [(UIRotationGestureRecognizer *) sender locationOfTouch:0 inView:self];
            CGPoint onePoint =
                    [(UIRotationGestureRecognizer *) sender locationOfTouch:1 inView:self];

            float pivotX = (zeroPoint.x + onePoint.x) / 2;
            float pivotY = (zeroPoint.y + onePoint.y) / 2;

            [self rotate:rotation pivotX:pivotX pivotY:pivotY];

            self.previousRotationPivotX = pivotX;
            self.previousRotationPivotY = pivotY;
        }
    } else if (state == UIGestureRecognizerStateEnded ||
            state == UIGestureRecognizerStateCancelled) {
        [self restore:self.previousRotationPivotX
 previousRotatePivotY:self.previousRotationPivotY];
    }
    self.previousRotation = [(UIRotationGestureRecognizer *) sender rotation];
    //    NSLog(@"rotation %f", [TransformUtility
    //    radian2Degree:self.previousRotation]);
}

CGAffineTransform CGAffineTransformFromRectToRect(CGRect fromRect,
        CGRect toRect) {
    CGAffineTransform trans1 =
            CGAffineTransformMakeTranslation(-fromRect.origin.x, -fromRect.origin.y);
    CGAffineTransform scale =
            CGAffineTransformMakeScale(toRect.size.width / fromRect.size.width,
                    toRect.size.height / fromRect.size.height);
    CGAffineTransform trans2 =
            CGAffineTransformMakeTranslation(toRect.origin.x, toRect.origin.y);
    return CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale),
            trans2);
}

- (void)     restore:(float)previousRotatePivotX
previousRotatePivotY:(float)previousRotatePivotY {
    if (self.switchBaseTransform || self.restoring) {
        return;
    }

    CGRect rect = CGRectMake(0, 0, [self getImageWidth], [self getImageHeight]);

    float currentRotation = [TransformUtility rotation:[self getDrawTransform]];
    CGRect nowRect = CGRectApplyAffineTransform(rect, [self getDrawTransform]);

    CGAffineTransform unRotatedTransform =
            [TransformUtility same:[self getDrawTransform]];
    unRotatedTransform = CGAffineTransformConcat(
            unRotatedTransform, [TransformUtility rotate:-currentRotation
                                                  pivotX:CGRectGetMidX(nowRect)
                                                  pivotY:CGRectGetMidY(nowRect)]);
    nowRect = CGRectApplyAffineTransform(rect, unRotatedTransform);

    int viewWidth = self.frame.size.width;
    int viewHeight = self.frame.size.height;

    float targetRotate =
            (float) floorf(([TransformUtility radian2Degree:currentRotation] + 45) /
                    90) *
                    90;
    targetRotate = [TransformUtility degree2Radian:targetRotate];

    CGAffineTransform dstTransform =
            [TransformUtility same:[self getDrawTransform]];

    //  if (currentRotation != 0) {
    //    dstTransform = CGAffineTransformConcat(
    //        dstTransform, [TransformUtility rotate:-currentRotation
    //                                        pivotX:CGRectGetMidX(nowRect)
    //                                        pivotY:CGRectGetMidY(nowRect)]);
    //  }

    float currentScale = [TransformUtility xScale:[self getDrawTransform]];
    float minScale = [TransformUtility xScale:self.baseFitCenterImageTransform];

    if (currentScale < minScale) {
        dstTransform = [self getMinTransform];
    } else if (currentScale > [self getMaxScale] * 0.7f) {
        //给人一种拉到最大又缩小回去的感觉
        float scale = [self getMaxScale] * 0.7f / currentScale;
        CGAffineTransform scaleTransform = [TransformUtility scale:scale
                                                            pivotX:viewWidth / 2
                                                            pivotY:viewHeight / 2];
        dstTransform = CGAffineTransformConcat(dstTransform, scaleTransform);
        // todo万一没贴边
    } else {
        // todo
        // 以原始Rect的中心做缩放旋转,错了,应该以当前屏幕中心点,不是srcRect中心点,也错了,是上次双指旋转的中心点……我日啊
        previousRotatePivotX =
                previousRotatePivotX != -1 ? previousRotatePivotX : viewWidth / 2;
        previousRotatePivotY =
                previousRotatePivotY != -1 ? previousRotatePivotY : viewHeight / 2;
        dstTransform = CGAffineTransformConcat(
                dstTransform, [TransformUtility rotate:targetRotate - currentRotation
                                                pivotX:previousRotatePivotX
                                                pivotY:previousRotatePivotY]);

        rect = CGRectMake(0, 0, [self getImageWidth], [self getImageHeight]);

        nowRect = CGRectApplyAffineTransform(rect, dstTransform);

        //高宽都小于View，所以移动位置到中心点
        if (nowRect.size.width <= self.frame.size.width &&
                nowRect.size.height <= self.frame.size.height) {
            CGFloat midX = CGRectGetMidX(nowRect);
            CGFloat midY = CGRectGetMidY(nowRect);

            CGFloat deltaX = self.frame.size.width / 2 - midX;
            CGFloat deltaY = self.frame.size.height / 2 - midY;

            CGAffineTransform nowTransform = dstTransform;
            CGAffineTransform nowTransform2 = CGAffineTransformMake(
                    nowTransform.a, nowTransform.b, nowTransform.c, nowTransform.d,
                    nowTransform.tx, nowTransform.ty);

            CGAffineTransform translationTransform =
                    CGAffineTransformMakeTranslation(deltaX, deltaY);
            nowTransform2 =
                    CGAffineTransformConcat(nowTransform2, translationTransform);

            CGAffineTransform animateTransform =
                    CGAffineTransformFromRectToRect(nowRect, rect);
            dstTransform = nowTransform2;
        } else {
            // todo float比较不应该直接这样比较的
            if (nowRect.size.width > viewWidth && nowRect.size.height < viewHeight) {
                CGAffineTransform nowTransform = dstTransform;

                CGAffineTransform nowTransform2 = CGAffineTransformMake(
                        nowTransform.a, nowTransform.b, nowTransform.c, nowTransform.d,
                        nowTransform.tx, nowTransform.ty);

                nowTransform2 = CGAffineTransformConcat(
                        nowTransform2, CGAffineTransformMakeTranslation(
                                0, viewHeight / 2 - CGRectGetMidY(nowRect)));

                if (nowRect.origin.x > 0) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(-nowRect.origin.x, 0));
                } else if (nowRect.origin.x + nowRect.size.width < viewWidth) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(
                                    viewWidth - nowRect.origin.x - nowRect.size.width, 0));
                }

                dstTransform = nowTransform2;
            } else if (nowRect.size.width < viewWidth &&
                    nowRect.size.height > viewHeight) {
                CGAffineTransform nowTransform = dstTransform;

                CGAffineTransform nowTransform2 = CGAffineTransformMake(
                        nowTransform.a, nowTransform.b, nowTransform.c, nowTransform.d,
                        nowTransform.tx, nowTransform.ty);

                nowTransform2 = CGAffineTransformConcat(
                        nowTransform2, CGAffineTransformMakeTranslation(
                                viewWidth / 2 - CGRectGetMidX(nowRect), 0));

                if (nowRect.origin.y > 0) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(0, -nowRect.origin.y));
                } else if (nowRect.origin.y + nowRect.size.height < viewHeight) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(
                                    0, viewHeight - nowRect.origin.y - nowRect.size.height));
                }

                dstTransform = nowTransform2;
            } else {
                //保证贴边
                CGAffineTransform nowTransform = dstTransform;

                CGAffineTransform nowTransform2 = CGAffineTransformMake(
                        nowTransform.a, nowTransform.b, nowTransform.c, nowTransform.d,
                        nowTransform.tx, nowTransform.ty);
                if (nowRect.origin.x > 0) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(-nowRect.origin.x, 0));
                }

                if (nowRect.origin.y > 0) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(0, -nowRect.origin.y));
                }

                if (nowRect.origin.x + nowRect.size.width < viewWidth) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(
                                    viewWidth - nowRect.origin.x - nowRect.size.width, 0));
                }

                if (nowRect.origin.y + nowRect.size.height < viewHeight) {
                    nowTransform2 = CGAffineTransformConcat(
                            nowTransform2,
                            CGAffineTransformMakeTranslation(
                                    0, viewHeight - nowRect.origin.y - nowRect.size.height));
                }

                dstTransform = nowTransform2;
            }
        }
    }

    self.restoring = YES;
    self.animator =
            [MatrixAnimator animator:self.imageLayer
                          fromMatrix:[self getDrawTransform]
                            toMatrix:dstTransform
                 exitCompletionBlock:^{
                     self.restoring = NO;
                     self.animator = nil;
                     [self updateCurrentDrawTransform:dstTransform animate:NO];
                     NSLog(@"归位动画结束");
                 }];
    [self.animator start];

    //    //相当于于左上角旋转+移动的动画啊我靠
    //
    //
    //    //todo 动画很奇怪啊,有旋转后,移动的位置很奇怪
    //    [self updateCurrentDrawTransform:sss animate:YES];

    //    self.restoring = YES;
    //    [UIView animateWithDuration:4.5
    //                          delay:0.0
    //                        options:UIViewAnimationOptionCurveLinear
    //                     animations:^{
    //                         [self updateCurrentDrawTransform:dstTransform
    //                         animate:YES];
    //                     }
    //                     completion:^(BOOL finished) {
    //                         self.restoring = NO;
    //                         NSLog(@"归位动画结束");
    //                     }];
}
@end

//
// Created by qii on 2/8/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import "ZoomScrollView.h"
#import "UIGestureRecognizer+BlocksKit.h"


// Private methods and properties
@interface ZoomScrollView () <UIScrollViewDelegate>
@property(strong, nonatomic) UIImageView *photoImageView;
@property(assign, nonatomic) NSUInteger index;
@property(strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property(strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation ZoomScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.index = NSUIntegerMax;
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.photoImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.photoImageView];

    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [self userDidDoubleTap:self.doubleTapGestureRecognizer];
    }];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.doubleTapGestureRecognizer];

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [self userDidTap:self.tapGestureRecognizer];
    }];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    [self addGestureRecognizer:self.tapGestureRecognizer];

    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    return self;
}

//fix strange UIScrollView cant scroll issue
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (ABS(self.zoomScale - self.minimumZoomScale) < 0.001 && [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]
            && gestureRecognizer.view == self) {
        return NO;
    }
    return YES;
}

#pragma mark - Image

- (void)setImage:(UIImage *)image {
    _image = image;
    if (_image == nil) {
        return;
    }
    [self displayImage];
}

// Get and display image
- (void)displayImage {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeZero;

    // Hide indicator

    // Set image
    self.photoImageView.image = self.image;
    self.photoImageView.hidden = NO;

    // Setup photo frame
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = self.image.size;
    self.photoImageView.frame = photoImageViewFrame;
    self.contentSize = photoImageViewFrame.size;

    // Set zoom to minimum zoom
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setNeedsLayout];
}

#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
//    if (self.photoImageView) {
//        // Zoom image to fill if the aspect ratios are fairly similar
//        CGSize boundsSize = self.bounds.size;
//        CGSize imageSize = self.photoImageView.image.size;
//        CGFloat boundsAR = boundsSize.width / boundsSize.height;
//        CGFloat imageAR = imageSize.width / imageSize.height;
//        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
//        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
//        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
//        if (ABS(boundsAR - imageAR) < 0.17) {
//            zoomScale = MAX(xScale, yScale);
//            // Ensure we don't zoom in or out too far, just in case
//            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
//        }
//    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {

    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;

    // Bail if no image
    if (self.photoImageView.image == nil) return;

    // Reset position
    self.photoImageView.frame = CGRectMake(0, 0, self.photoImageView.frame.size.width, self.photoImageView.frame.size.height);

    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.photoImageView.image.size;

    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible

    // Calculate Max
    CGFloat maxScale = MAX(4, minScale + 1);

    // Image is smaller than screen so no zooming!
//    if (xScale >= 1 && yScale >= 1) {
//        minScale = 1.0;
//    }

    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;

    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];

    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.scrollEnabled = NO;
    }

    // Layout
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
    // Super
    [super layoutSubviews];

    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.photoImageView.frame;

    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }

    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }

    // Center
    if (!CGRectEqualToRect(self.photoImageView.frame, frameToCenter))
        self.photoImageView.frame = frameToCenter;

}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    ((UIScrollView *)self.superview).scrollEnabled= NO;

}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    if (self.singleTapBlock != nil) {
        self.singleTapBlock();
    }
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y - ysize / 2, xsize, ysize) animated:YES];
    }
}

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    CGPoint translationCurrentPoint = [recognizer locationInView:self.photoImageView];
    CGFloat touchX = translationCurrentPoint.x;
    CGFloat touchY = translationCurrentPoint.y;
    [self handleSingleTap:CGPointMake(touchX, touchY)];
}

- (void)userDidDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint translationCurrentPoint = [recognizer locationInView:self.photoImageView];
    CGFloat touchX = translationCurrentPoint.x;
    CGFloat touchY = translationCurrentPoint.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}
@end

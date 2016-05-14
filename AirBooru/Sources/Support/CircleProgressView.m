//
// Created by qii on 5/2/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "CircleProgressView.h"

@interface CircleProgressView ()
@property(strong, nonatomic) UIBezierPath *bezierPath;
@property(strong, nonatomic) UIBezierPath *leftBezierPath;
@property(assign, nonatomic) CGFloat startAngle;
@property(assign, nonatomic) CGFloat endAngle;
@end

@implementation CircleProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

        // Determine our start and stop angles for the arc (in radians)
        self.startAngle = M_PI * 1.5;
        self.endAngle = self.startAngle + (M_PI * 2);

        self.bezierPath = [UIBezierPath bezierPath];
        self.leftBezierPath = [UIBezierPath bezierPath];
    }
    return self;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    int lineWidth = 5;
    int radius = (int) (CGRectGetWidth(self.bounds) / 2) - 10;

    [self.bezierPath removeAllPoints];
    [self.bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                               radius:radius
                           startAngle:self.startAngle
                             endAngle:(self.endAngle - self.startAngle) * (_progress) + self.startAngle
                            clockwise:YES];

    // Set the display for the path, and stroke it
    self.bezierPath.lineWidth = lineWidth;

    [self.leftBezierPath removeAllPoints];
    self.leftBezierPath.lineWidth = lineWidth;
    [self.leftBezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                                   radius:radius
                               startAngle:(self.endAngle - self.startAngle) * (_progress) + self.startAngle
                                 endAngle:self.endAngle
                                clockwise:YES];

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, 5.0);
    CGContextSetLineCap(currentContext, kCGLineCapRound);

    {
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [[UIColor lightGrayColor] getRed:&red green:&green blue:&blue alpha:&alpha];
        CGContextSetRGBStrokeColor(currentContext, red, green, blue, alpha);
        CGContextBeginPath(currentContext);
        CGContextAddPath(currentContext, self.leftBezierPath.CGPath);
        CGContextDrawPath(currentContext, kCGPathStroke);
//        CGContextClosePath(currentContext);
    }
    {
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [self.tintColor getRed:&red green:&green blue:&blue alpha:&alpha];
        CGContextSetRGBStrokeColor(currentContext, red, green, blue, alpha);
        CGContextBeginPath(currentContext);
        CGContextAddPath(currentContext, self.bezierPath.CGPath);
        CGContextDrawPath(currentContext, kCGPathStroke);
//        CGContextClosePath(currentContext);
    }
}

//
//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineCap(context, kCGLineCapRound);
//
//    int lineWidth = 5;
//    int radius = (int) (CGRectGetWidth(self.bounds) / 2) - 10;
//
//    [self.bezierPath removeAllPoints];
//    [self.bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
//                               radius:radius
//                           startAngle:self.startAngle
//                             endAngle:(self.endAngle - self.startAngle) * (_progress) + self.startAngle
//                            clockwise:YES];
//
//    // Set the display for the path, and stroke it
//    self.bezierPath.lineWidth = lineWidth;
//    [self.tintColor setStroke];
//    [self.bezierPath stroke];
//
//    [self.leftBezierPath removeAllPoints];
//    self.leftBezierPath.lineWidth = lineWidth;
//    [self.leftBezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
//                                   radius:radius
//                               startAngle:(self.endAngle - self.startAngle) * (_progress) + self.startAngle
//                                 endAngle:self.endAngle
//                                clockwise:YES];
//    [[UIColor lightGrayColor] setStroke];
//    [self.leftBezierPath stroke];
//
//    // Text Drawing
////    CGRect textRect = CGRectMake((rect.size.width / 2.0) - 71 / 2.0, (rect.size.height / 2.0) - 45 / 2.0, 71, 45);
////    [[UIColor blackColor] setFill];
////
////    // Display our percentage as a string
////    NSString *textContent = [NSString stringWithFormat:@"%f", self.progress];
////    [textContent drawInRect:textRect withFont:[UIFont fontWithName:@"Helvetica-Bold" size:42.5] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
//}

@end
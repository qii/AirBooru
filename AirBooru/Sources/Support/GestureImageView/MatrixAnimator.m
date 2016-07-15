#import "MatrixAnimator.h"

@interface MatrixAnimator ()
@property(strong, nonatomic) CALayer *layer;
@property(assign, nonatomic) CGAffineTransform fromMatrix;
@property(assign, nonatomic) CGAffineTransform toMatrix;

@property(copy, nonatomic) AnimatorExitCompletionBlock exitCompletionBlock;

@property(nonatomic, strong) CADisplayLink *timer;
@property(nonatomic, assign) CFTimeInterval duration;
@property(nonatomic, assign) CFTimeInterval timeOffset;
@property(nonatomic, assign) CFTimeInterval lastStep;

@end

@implementation MatrixAnimator

+ (instancetype)animator:(CALayer *)layer
              fromMatrix:(CGAffineTransform)fromMatrix
                toMatrix:(CGAffineTransform)toMatrix
     exitCompletionBlock:(AnimatorExitCompletionBlock)exitCompletionBlock {
    MatrixAnimator *animator = [[MatrixAnimator alloc] init];
    animator.layer = layer;
    animator.fromMatrix = fromMatrix;
    animator.toMatrix = toMatrix;
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
    self.duration = 0.3f;
    self.timeOffset = 0.0;
    self.lastStep = CACurrentMediaTime();
    self.timer =
            [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop]
                     forMode:NSDefaultRunLoopMode];
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

    float a = (1 - time) * self.fromMatrix.a + time * self.toMatrix.a;
    float b = (1 - time) * self.fromMatrix.b + time * self.toMatrix.b;
    float c = (1 - time) * self.fromMatrix.c + time * self.toMatrix.c;
    float d = (1 - time) * self.fromMatrix.d + time * self.toMatrix.d;
    float tx = (1 - time) * self.fromMatrix.tx + time * self.toMatrix.tx;
    float ty = (1 - time) * self.fromMatrix.ty + time * self.toMatrix.ty;
    CGAffineTransform transform = CGAffineTransformMake(a, b, c, d, tx, ty);

    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.layer.affineTransform = transform;
    [CATransaction commit];

    if (self.timeOffset >= self.duration) {
        [self.timer invalidate];
        self.timer = nil;
        if (self.exitCompletionBlock != nil) {
            self.exitCompletionBlock();
        }
    }
}

@end
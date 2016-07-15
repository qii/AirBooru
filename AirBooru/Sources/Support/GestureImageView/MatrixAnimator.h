#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef void (^AnimatorExitCompletionBlock)();

@interface MatrixAnimator : NSObject

+ (instancetype)animator:(CALayer *)layer
              fromMatrix:(CGAffineTransform)fromMatrix
                toMatrix:(CGAffineTransform)toMatrix
     exitCompletionBlock:(AnimatorExitCompletionBlock)exitCompletionBlock;

- (void)start;
@end
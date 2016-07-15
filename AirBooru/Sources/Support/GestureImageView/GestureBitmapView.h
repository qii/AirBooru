//
//  GestureBitmapView.h
//  BitmapView
//
//  Created by qii on 7/11/16.
//  Copyright © 2016 qii. All rights reserved.
//

#import "BitmapView.h"
typedef void (^SingleTapBlock)();

@interface GestureBitmapView : BitmapView
@property(copy, nonatomic) SingleTapBlock singleTapBlock;
@end

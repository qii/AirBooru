//
// Created by qii on 5/10/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface ImageHelper : NSObject
+ (UIImage *)scaleImageToSize:(UIImage *)image size:(CGSize)size;

+ (BOOL)canReadImageAt:(NSString *)path;

+ (NSUInteger)calcImageMemCacheCost:(UIImage *)image;
@end
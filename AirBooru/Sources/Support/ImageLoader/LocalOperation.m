//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LocalOperation.h"

@interface LocalOperation ()

@end

@implementation LocalOperation

+ (instancetype)operationWithPath:(NSString *)localCacheFile {
    LocalOperation *operation = [[LocalOperation alloc] init];
    operation.localCacheFile = localCacheFile;
    return operation;
}

- (void)main {
    UIImage *image = [UIImage imageWithContentsOfFile:self.localCacheFile];
    if (image != nil) {
        image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        //todo file is interrupted,remove cache file and db cache
    }

    if (self.resultBlock != nil) {
        self.resultBlock(image);
    }
}

@end
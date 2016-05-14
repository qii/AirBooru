//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;@class ImageLoaderOption;

typedef void (^ABUImageLoaderSuccessBlock)(NSString *url, UIImage *image);

typedef void (^ABUImageLoaderPercentBlock)(NSString *url, float percent);

typedef void (^ABUImageLoaderFailureBlock)(NSString *url, NSError *error);

typedef void (^ABUImageLoaderQueryCacheFileBlock)(NSString *url, NSString *cacheFile, NSError *error);


@interface ImageLoader : NSObject

+ (instancetype)sharedInstance;

- (void)loadImage:(NSString *)url option:(ImageLoaderOption *)option;

- (void)cancelLoadImage:(NSString *)url;

- (void)queryCacheFile:(NSString *)url block:(ABUImageLoaderQueryCacheFileBlock)block;
@end
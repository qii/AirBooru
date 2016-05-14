//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageLoader.h"


@interface ImageBlockOperation : NSBlockOperation
@property(copy, nonatomic) NSString *url;

- (void)addOption:(ImageLoaderOption *)option;

- (void)addOptions:(NSArray *)options;

- (NSArray *)allOptions;

@end
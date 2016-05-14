//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TagList;
@class ImageBoard2;

typedef void (^TagListApiBlock)(TagList *request, NSError *error);

typedef void (^TagListApiSearchBlock)(TagList *request, NSError *error);

@interface TagListApi : NSObject
@property(nonatomic, strong) ImageBoard2 *imageBoard;
@property(copy, nonatomic) TagListApiBlock block;
@property(nonatomic, copy) TagListApiSearchBlock searchBlock;

- (void)loadLatestData;

- (void)loadPreviousData;

- (void)searchTagName:(NSString *)tagName;
@end
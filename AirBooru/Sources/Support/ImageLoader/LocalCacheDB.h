//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

#import "OpenSQLiteDatabase.h"

@interface LocalCacheDB : OpenSQLiteDatabase

- (void)clearCache;

- (void)deleteCache:(NSString *)url;

- (NSString *)generateCacheFile;

- (NSString *)queryCacheFile:(NSString *)url;

- (void)updateCache:(NSString *)url file:(NSString *)cacheFile;

- (void)setMaxCacheSize:(long long)size;

- (void)trimCache:(long long)totalSize maxSize:(long long)maxSize;

@end


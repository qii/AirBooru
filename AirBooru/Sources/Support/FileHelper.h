//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

//
// Created by qii on 3/9/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileHelper : NSObject

+ (NSString *)getAbsolutePath:(NSString *)relativePath;

+ (NSString *)getRelativePath:(NSString *)absolutePath;

+ (NSString *)getSharedAbsolutePath:(NSString *)relativePath;

+ (NSString *)getSharedRelativePath:(NSString *)absolutePath;

+ (NSString *)getExternalSupportDir;

+ (NSString *)getExternalSupportFile:(NSString *)name;

+ (NSString *)getExternalCacheDir;

+ (NSString *)getExternalSubCacheDir:(NSString *)dirName;

+ (NSString *)getExternalCacheFile:(NSString *)name createIfNotExsit:(BOOL)createIfNotExsit;

+ (NSString *)getExternalTempDir;

+ (NSString *)getExternalTempFile:(NSString *)name;

+ (NSString *)getFilePath:(NSString *)dirPath file:(NSString *)name;

+ (BOOL)isFileEmpty:(NSString *)path;

+ (BOOL)isFileExists:(NSString *)path;

+ (long long)fileSize:(NSString *)path;

+ (void)deleteFile:(NSString *)path;

+ (NSString *)getFormatLength:(long long)size;

+ (NSString *)generateTmpFile;

+ (NSArray *)queryChildren:(NSString *)directory;

+ (double)getModifiedTime:(NSString *)path;
@end
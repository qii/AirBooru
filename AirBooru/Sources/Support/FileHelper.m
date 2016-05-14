//
// Created by qii on 3/9/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import "FileHelper.h"

@implementation FileHelper

+ (NSString *)getAbsolutePath:(NSString *)relativePath {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    int location = NSNotFound;
    if ([directory hasPrefix:@"/Users/"]) {
        NSString *word = @"Library";
        NSRange range = [directory rangeOfString:word options:NSBackwardsSearch];
        location = range.location;
        if (location != NSNotFound) {
            location = location + range.length;
        }
    } else if ([directory hasPrefix:@"/var/mobile/"]) {
        NSString *word = @"Library";
        NSRange range = [directory rangeOfString:word];
        location = range.location;
    }

    if (location != NSNotFound) {
        NSString *rootPath = [directory substringToIndex:location];
        return [NSString stringWithFormat:@"%@%@", rootPath, relativePath];
    }
    return nil;
}

+ (NSString *)getRelativePath:(NSString *)absolutePath {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    int location = NSNotFound;
    if ([directory hasPrefix:@"/Users/"]) {
        NSString *word = @"Library";
        NSRange range = [absolutePath rangeOfString:word options:NSBackwardsSearch];
        location = range.location;
        if (location != NSNotFound) {
            location = location + range.length;
        }
    } else if ([directory hasPrefix:@"/var/mobile/"]) {
        NSString *word = @"Library";
        NSRange range = [absolutePath rangeOfString:word];
        location = range.location;
    }
    if (location != NSNotFound) {
        NSString *relativePath = [absolutePath substringFromIndex:location];
        return relativePath;
    }
    return nil;
}

+ (NSString *)getSharedAbsolutePath:(NSString *)relativePath {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    int location = NSNotFound;
    if ([directory hasPrefix:@"/Users/"]) {
        NSString *word = @"Documents";
        NSRange range = [directory rangeOfString:word options:NSBackwardsSearch];
        location = range.location;
        if (location != NSNotFound) {
            location = location + range.length;
        }
    } else if ([directory hasPrefix:@"/var/mobile/"]) {
        NSString *word = @"Documents";
        NSRange range = [directory rangeOfString:word];
        location = range.location;
    }

    if (location != NSNotFound) {
        NSString *rootPath = [directory substringToIndex:location];
        return [NSString stringWithFormat:@"%@%@", rootPath, relativePath];
    }
    return nil;
}

+ (NSString *)getSharedRelativePath:(NSString *)absolutePath {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    int location = NSNotFound;
    if ([directory hasPrefix:@"/Users/"]) {
        NSString *word = @"Documents";
        NSRange range = [absolutePath rangeOfString:word];
        location = range.location;
        if (location != NSNotFound) {
            location = location;
        }
    } else if ([directory hasPrefix:@"/var/mobile/"]) {
        NSString *word = @"Documents";
        NSRange range = [absolutePath rangeOfString:word];
        location = range.location;
    }
    if (location != NSNotFound) {
        NSString *relativePath = [absolutePath substringFromIndex:location];
        return relativePath;
    }
    return nil;
}

+ (NSString *)getExternalSupportDir {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    [directory stringByAppendingPathComponent:@"/org.qii.airbooru/support"];
    [FileHelper createIfNotExistsDir:directory];
    return directory;
}

+ (NSString *)getExternalSupportFile:(NSString *)name {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    NSString *file = [NSString stringWithFormat:@"%@%@/%@", directory, @"/org.qii.airbooru/support", name];
    [FileHelper createIfNotExistsFile:[file stringByDeletingLastPathComponent] file:file];
    return file;
}

+ (NSString *)getExternalCacheDir {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    [directory stringByAppendingPathComponent:@"/org.qii.airbooru/cache"];
    [FileHelper createIfNotExistsDir:directory];
    return directory;
}

+ (NSString *)getExternalSubCacheDir:(NSString *)dirName {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    directory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", @"/org.qii.airbooru/cache", dirName]];
    [FileHelper createIfNotExistsDir:directory];
    return directory;
}

+ (NSString *)getExternalCacheFile:(NSString *)name createIfNotExsit:(BOOL)createIfNotExsit {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    NSString *file = [NSString stringWithFormat:@"%@%@/%@", directory, @"/org.qii.airbooru/cache", name];
    [FileHelper createIfNotExistsDir:[file stringByDeletingLastPathComponent]];
    if (createIfNotExsit)
        [FileHelper createIfNotExistsFile:[file stringByDeletingLastPathComponent] file:file];
    return file;
}

+ (NSString *)getExternalTempDir {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    directory = [directory stringByAppendingPathComponent:@"/org.qii.airbooru/tmp"];
    [FileHelper createIfNotExistsDir:directory];
    return directory;
}

+ (NSString *)getExternalTempFile:(NSString *)name {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [cachePathArray lastObject];
    NSString *file = [NSString stringWithFormat:@"%@%@/%@", directory, @"/org.qii.airbooru/tmp", name];
    [FileHelper createIfNotExistsFile:[file stringByDeletingLastPathComponent] file:file];
    return file;
}

+ (NSString *)getFilePath:(NSString *)dirPath file:(NSString *)name {
    NSString *path;
    if ([dirPath hasSuffix:@"/"]) {
        path = [NSString stringWithFormat:@"%@%@", dirPath, name];
    } else {
        path = [NSString stringWithFormat:@"%@/%@", dirPath, name];
    }
    [FileHelper createIfNotExistsFile:[path stringByDeletingLastPathComponent] file:path];
    return path;
}

+ (BOOL)isFileEmpty:(NSString *)path {
    uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    return fileSize == 0;
}

+ (BOOL)isFileExists:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

+ (long long)fileSize:(NSString *)path {
    uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    return fileSize;
}

+ (void)deleteFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

+ (NSString *)getFormatLength:(long long)size {
    if (size >= 1024 * 1024) {
        return [NSString stringWithFormat:@"%lld Mb", (size / (1024 * 1024))];
    } else if (size >= 1024) {
        return [NSString stringWithFormat:@"%lld Kb", (size / (1024))];
    } else {
        return [NSString stringWithFormat:@"%lld b", (size)];
    }
}

+ (NSString *)generateTmpFile {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    long long time = (long long) timeStamp;
    NSString *name = [NSString stringWithFormat:@"%llu_%d.jpg", time, arc4random_uniform(INT_MAX)];
    return [FileHelper getFilePath:[FileHelper getExternalTempDir] file:name];
}

+ (NSArray *)queryChildren:(NSString *)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directory error:&error];
    return files;
}

+ (void)createIfNotExistsFile:(NSString *)dir file:(NSString *)file {
    [FileHelper createIfNotExistsDir:dir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:file]) {
        BOOL result = [fileManager createFileAtPath:file contents:[NSData data] attributes:nil];
        if (!result) {
            NSLog(@"FileHelper create file error was code: %d - message: %s", errno, strerror(errno));
        }
    }
}

+ (void)createIfNotExistsDir:(NSString *)dir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"FileHelper create dir error %@", error);
            return;
        }
    }
}

+ (NSString *)checkPathScheme:(NSString *)path {
    if ([path hasPrefix:@"file://"]) {
        return [path substringFromIndex:@"file://".length];
    } else {
        return path;
    }
}

+ (double)getModifiedTime:(NSString *)path {
    path = [FileHelper checkPathScheme:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attr = [fileManager attributesOfItemAtPath:path error:&error];
    NSDate *date = attr[NSFileModificationDate];
    return date.timeIntervalSince1970;
//    NSString *formatTime = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle];
//    return formatTime;
}
@end
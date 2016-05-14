//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LocalCacheDB.h"
#import "FileHelper.h"
#import "SQLHelper.h"

static NSString *const ABUTableCache = @"cache";
static NSString *const ABUColumnUrl = @"url";
static NSString *const ABUColumnPath = @"path";
static NSString *const ABUColumnFileSize = @"file_size";
static NSString *const ABUColumnLastAccessedTime = @"last_accessed_time";

static NSString *const ABUTableFileName = @"yandere";
static int const ABUTableVersion = 1;

static int const LocalCacheDBMaxSizeMb = 300;

@interface LocalCacheDB ()
@property(strong, nonatomic) NSString *cacheDir;
@property(assign, nonatomic) long long maxCacheSize;
@end

@implementation LocalCacheDB

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxCacheSize = 1024 * 1024 * LocalCacheDBMaxSizeMb;
        [self open:ABUTableFileName version:ABUTableVersion];
    }
    return self;
}

#pragma mark - Database init

- (void)databaseCreate {
    NSDictionary *columns = @{
            ABUColumnUrl : @"TEXT UNIQUE",
            ABUColumnPath : @"TEXT",
            ABUColumnFileSize : @"INTEGER",
            ABUColumnLastAccessedTime : @"INTEGER",
    };
    NSString *sql = [SQLHelper buildCreateTableSQL:ABUTableCache columns:columns];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"FileSQLCache Failed to create table %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
    }
}

- (void)databaseDowngrade:(int)currentVersion newVersion:(int)newVersion {
    NSString *sql = [SQLHelper buildDropTableSQL:ABUTableCache];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"FileSQLCache Failed to onDowngrade %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
    }
    [self databaseCreate];
}

- (void)databaseUpgrade:(int)currentVersion newVersion:(int)newVersion {
    NSString *sql = [SQLHelper buildDropTableSQL:ABUTableCache];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"FileSQLCache Failed to onUpgrade %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
    }
    [self databaseCreate];
}

#pragma mark - Cache action

- (void)clearCache {

}

- (void)deleteCache:(NSString *)url {
    @synchronized (self) {
        NSString *sql = [SQLHelper buildDeleteSQL:ABUTableCache where:@{ABUColumnUrl : url}];
        sqlite3_stmt *deleteStmt = nil;
        const char *del_stmt = [sql UTF8String];
        sqlite3_prepare_v2(self.database, del_stmt, -1, &deleteStmt, NULL);
        if (sqlite3_step(deleteStmt) == SQLITE_DONE) {
            NSLog(@"FileSQLCache delete a row");
        } else {
            NSLog(@"FileSQLCache delete a row failed '%s'", sqlite3_errmsg(self.database));
        }
        sqlite3_finalize(deleteStmt);
    }
}

- (NSString *)generateCacheFile {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    long long time = (long long) timeStamp;
    NSString *name = [NSString stringWithFormat:@"%llu_%d.jpg", time, arc4random_uniform(INT_MAX)];
    return [FileHelper getFilePath:self.cacheDir file:name];
}

- (NSString *)queryCacheFile:(NSString *)url {
    @synchronized (self) {
        NSArray *columns = @[ABUColumnPath];
        NSDictionary *where = @{ABUColumnUrl : url};
        NSString *sql = [SQLHelper buildQuerySQL:ABUTableCache columns:columns where:where];
        const char *query_stmt = [sql UTF8String];
        sqlite3_stmt *queryStmt = nil;
        NSString *result = nil;
        if (sqlite3_prepare_v2(self.database, query_stmt, -1, &queryStmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(queryStmt) == SQLITE_ROW) {
                NSString *filePath = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(queryStmt, 0)];
                filePath = [FileHelper getAbsolutePath:filePath];
//                NSLog(@"FileSQLCache query find cached file %@", filePath);
                long long itemLastModified = sqlite3_column_int64(queryStmt, 1);
                BOOL exists = [FileHelper isFileExists:filePath];
                BOOL isEmpty = [FileHelper isFileEmpty:filePath];
                if (exists && !isEmpty) {
                    [self updateStamp:url];
                    result = filePath;
                } else {
                    NSLog(@"FileSQLCache cached file is not exist or empy, so delete it");
                    [self deleteCache:url];
                }
            }
            sqlite3_finalize(queryStmt);
        }
        return result;
    }
}

- (void)updateStamp:(NSString *)id {
    @synchronized (self) {
        double timeStamp = [[NSDate date] timeIntervalSince1970];
        long long time = (long long) timeStamp;
        NSDictionary *value = @{ABUColumnLastAccessedTime : @(time).stringValue};
        const char *sql = [SQLHelper buildUpdateSQL:ABUTableCache values:value where:@{ABUColumnUrl : id}].UTF8String;
        sqlite3_stmt *updateStmt = nil;
        char *errMsg;
        if (sqlite3_exec(self.database, sql, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"FileSQLCache Failed to updateStamp %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
        }
        sqlite3_finalize(updateStmt);
    }
}

- (long long)getTotalCacheSize {
    @synchronized (self) {
        NSString *sql = [SQLHelper buildSumSQL:ABUTableCache column:ABUColumnFileSize];
        const char *query_stmt = [sql UTF8String];
        sqlite3_stmt *queryStmt = nil;
        if (sqlite3_prepare_v2(self.database, query_stmt, -1, &queryStmt, NULL) == SQLITE_OK) {
            if (sqlite3_step(queryStmt) == SQLITE_ROW) {
                long long sum = sqlite3_column_int64(queryStmt, 0);
                NSLog(@"FileSQLCache cache size:%@", [FileHelper getFormatLength:sum]);
                return sum;
            }
            sqlite3_finalize(queryStmt);
        }
    }
    return 0;
}

- (void)setMaxCacheSize:(long long)size {
    _maxCacheSize = size;
}

//todo limit 80 cache
- (void)trimCache:(long long)totalSize maxSize:(long long)maxSize {
    @synchronized (self) {
        NSMutableArray *files = [[NSMutableArray alloc] init];
        NSString *sql = [SQLHelper buildQuerySQL:ABUTableCache columns:@[ABUColumnUrl, ABUColumnFileSize, ABUColumnPath] where:nil order:[NSString stringWithFormat:@"%@ asc", ABUColumnLastAccessedTime]];
        const char *query_stmt = [sql UTF8String];
        sqlite3_stmt *queryStmt = nil;
        if (sqlite3_prepare_v2(self.database, query_stmt, -1, &queryStmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(queryStmt) == SQLITE_ROW) {
                NSString *id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(queryStmt, 0)];
                long long size = sqlite3_column_int64(queryStmt, 1);
                NSString *filePath = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(queryStmt, 2)];
                filePath = [FileHelper getAbsolutePath:filePath];
                [files addObject:filePath];
                [self deleteCache:id];

                totalSize -= size;
                if (totalSize < (maxSize * 0.8f)) {
                    break;
                }
            }
            sqlite3_finalize(queryStmt);
        }

        for (NSString *file in files) {
            [FileHelper deleteFile:file];
        }

        NSLog(@"FileSQLCache delete cache:%d", files.count);
    }
}

- (void)updateCache:(NSString *)url file:(NSString *)cacheFile {
    @synchronized (self) {
        long long currentCacheSize = [self getTotalCacheSize];
        if (currentCacheSize > self.maxCacheSize) {
            [self trimCache:currentCacheSize maxSize:self.maxCacheSize];
        }

        long long size = [FileHelper fileSize:cacheFile];
        double timeStamp = [[NSDate date] timeIntervalSince1970];
        NSDictionary *values = @{
                ABUColumnUrl : url,
                ABUColumnPath : [FileHelper getRelativePath:cacheFile],
                ABUColumnFileSize : @(size).stringValue,
                ABUColumnLastAccessedTime : @(timeStamp).stringValue};
        NSString *sql = [SQLHelper buildReplaceSQL:ABUTableCache values:values];
        sqlite3_stmt *updateStmt = nil;
        char *errMsg;
        if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"FileSQLCache Failed to updateCache %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
        }
        sqlite3_finalize(updateStmt);
    }
}

@end
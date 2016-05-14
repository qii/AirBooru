//
// Created by qii on 7/10/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <sqlite3.h>
#import "FavouriteDB.h"
#import "SQLHelper.h"
#import "Post.h"
#import "UrlHelper.h"

static NSString *const ABUTableCache = @"favourite";
static NSString *const ABUColumnId = @"post_id";
static NSString *const ABUColumnJSONData = @"json_data";
static NSString *const ABUColumnCreatedTime = @"created_time";

static NSString *const ABUTableFileName = @"favourite";
static int const ABUTableVersion = 1;

@interface FavouriteDB ()
@end

@implementation FavouriteDB

+ (instancetype)sharedInstance {
    static FavouriteDB *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[FavouriteDB alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self open:ABUTableFileName version:ABUTableVersion];
    }
    return self;
}

#pragma mark - Database init

- (void)databaseCreate {
    NSDictionary *columns = @{
            ABUColumnId : @"TEXT UNIQUE",
            ABUColumnJSONData : @"TEXT",
            ABUColumnCreatedTime : @"INTEGER",
    };
    NSString *sql = [SQLHelper buildCreateTableSQL:ABUTableCache columns:columns];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"FavouriteDB Failed to create table %@", [NSString stringWithCString:errMsg]);
    }
}

- (void)databaseDowngrade:(int)currentVersion newVersion:(int)newVersion {
    NSString *sql = [SQLHelper buildDropTableSQL:ABUTableCache];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"FavouriteDB Failed to onDowngrade %@", [NSString stringWithCString:errMsg]);
    }
    [self databaseCreate];
}

- (void)databaseUpgrade:(int)currentVersion newVersion:(int)newVersion {
    NSString *sql = [SQLHelper buildDropTableSQL:ABUTableCache];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"FavouriteDB Failed to onUpgrade %@", [NSString stringWithCString:errMsg]);
    }
    [self databaseCreate];
}

#pragma mark - Favourite action

- (void)deletePost:(long long)postId {
    @synchronized (self) {
        NSString *sql = [SQLHelper buildDeleteSQL:ABUTableCache where:@{ABUColumnId : @(postId).stringValue}];
        sqlite3_stmt *deleteStmt = nil;
        const char *del_stmt = [sql UTF8String];
        sqlite3_prepare_v2(self.database, del_stmt, -1, &deleteStmt, NULL);
        if (sqlite3_step(deleteStmt) == SQLITE_DONE) {
            NSLog(@"FavouriteDB delete a row");
        } else {
            NSLog(@"FavouriteDB delete a row failed '%s'", sqlite3_errmsg(self.database));
        }
        sqlite3_finalize(deleteStmt);
    }
}

- (NSArray *)query {
    @synchronized (self) {
        NSArray *columns = @[ABUColumnJSONData];
        NSString *sql = [SQLHelper buildQuerySQL:ABUTableCache columns:columns where:nil order:[NSString stringWithFormat:@"%@ desc", ABUColumnCreatedTime]];
        const char *query_stmt = [sql UTF8String];
        sqlite3_stmt *queryStmt = nil;

        NSMutableArray *result = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(self.database, query_stmt, -1, &queryStmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(queryStmt) == SQLITE_ROW) {
                NSString *jsonData = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(queryStmt, 0)];
                if (jsonData) {
                    jsonData = [UrlHelper decode:jsonData];
                    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error = nil;
                    id jsonObjects = [NSJSONSerialization JSONObjectWithData:
                            data                                     options:NSJSONReadingMutableContainers error:&error];
                    Post *post = [Post parseJSON:(NSDictionary *) jsonObjects];
                    [result addObject:post];
                } else {
                    NSLog(@"FavouriteDB cached file is not exist or empy, so delete it");
                }
            }
            sqlite3_finalize(queryStmt);
        }
        return [NSArray arrayWithArray:result];
    }
}

- (BOOL)isFavourite:(long long)postId {
    @synchronized (self) {
        NSArray *columns = @[ABUColumnJSONData];
        NSDictionary *where = @{ABUColumnId : @(postId).stringValue};
        NSString *sql = [SQLHelper buildQuerySQL:ABUTableCache columns:columns where:where];
        const char *query_stmt = [sql UTF8String];
        sqlite3_stmt *queryStmt = nil;

        BOOL result = NO;
        if (sqlite3_prepare_v2(self.database, query_stmt, -1, &queryStmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(queryStmt) == SQLITE_ROW) {
                NSString *jsonData = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(queryStmt, 0)];
                if (jsonData) {
                    result = YES;
                } else {
                    NSLog(@"FavouriteDB cached file is not exist or empy, so delete it");
                }
            }
            sqlite3_finalize(queryStmt);
        }
        return result;
    }
}

- (void)addPost:(Post *)post {
    @synchronized (self) {
        double timeStamp = [[NSDate date] timeIntervalSince1970];
        NSDictionary *values = @{
                ABUColumnId : @(post.postId).stringValue,
                ABUColumnJSONData : [UrlHelper encode:[post toJSON]],
                ABUColumnCreatedTime : @(timeStamp).stringValue};
        NSString *sql = [SQLHelper buildReplaceSQL:ABUTableCache values:values];
        sqlite3_stmt *updateStmt = nil;
        char *errMsg;
        if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"FavouriteDB Failed to updateCache %@", [NSString stringWithCString:errMsg]);
        }
        sqlite3_finalize(updateStmt);
    }
}


@end
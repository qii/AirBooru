//
// Created by qii on 7/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "HomeDB.h"
#import "SQLHelper.h"
#import "UrlHelper.h"
#import "Post.h"

static NSString *const ABUTableCache = @"home";
static NSString *const ABUColumnTagName = @"tag";
static NSString *const ABUColumnId = @"post_id";
static NSString *const ABUColumnJSONData = @"json_data";

static int const ABUTableVersion = 1;

@interface HomeDB ()
@end

@implementation HomeDB

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)open:(NSString *)serverIdentifyId {
    [self open:serverIdentifyId version:ABUTableVersion];
}

#pragma mark - Database init

- (void)databaseCreate {
    NSDictionary *columns = @{
            ABUColumnId : @"TEXT UNIQUE",
            ABUColumnJSONData : @"TEXT"
    };
    NSString *sql = [SQLHelper buildCreateTableSQL:ABUTableCache columns:columns];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"HomeDB Failed to create table %@", [NSString stringWithCString:errMsg]);
    }
}

- (void)databaseDowngrade:(int)currentVersion newVersion:(int)newVersion {
    NSString *sql = [SQLHelper buildDropTableSQL:ABUTableCache];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"HomeDB Failed to onDowngrade %@", [NSString stringWithCString:errMsg]);
    }
    [self databaseCreate];
}

- (void)databaseUpgrade:(int)currentVersion newVersion:(int)newVersion {
    NSString *sql = [SQLHelper buildDropTableSQL:ABUTableCache];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"HomeDB Failed to onUpgrade %@", [NSString stringWithCString:errMsg]);
    }
    [self databaseCreate];
}

- (void)clear {
    @synchronized (self) {
        NSString *sql = [SQLHelper buildDeleteAllSQL:ABUTableCache];
        sqlite3_stmt *deleteStmt = nil;
        const char *del_stmt = [sql UTF8String];
        sqlite3_prepare_v2(self.database, del_stmt, -1, &deleteStmt, NULL);
        if (sqlite3_step(deleteStmt) == SQLITE_DONE) {
            NSLog(@"HomeDB clear rows");
        } else {
            NSLog(@"HomeDB clear rows failed '%s'", sqlite3_errmsg(self.database));
        }
        sqlite3_finalize(deleteStmt);
    }
}

- (NSArray *)query {
    @synchronized (self) {
        NSArray *columns = @[ABUColumnJSONData];
        NSString *sql = [SQLHelper buildQuerySQL:ABUTableCache columns:columns where:nil order:[NSString stringWithFormat:@"%@ desc", ABUColumnId]];
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
                    NSLog(@"HomeDB cached file is not exist or empy, so delete it");
                }
            }
            sqlite3_finalize(queryStmt);
        }
        return [NSArray arrayWithArray:result];
    }
}

- (void)addPosts:(NSArray *)posts {
    [self clear];
    @synchronized (self) {
        double timeStamp = [[NSDate date] timeIntervalSince1970];
        char *errorMessage;
        sqlite3_exec(self.database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
        for (Post *post in posts) {
            NSDictionary *values = @{
                    ABUColumnId : @(post.postId).stringValue,
                    ABUColumnJSONData : [UrlHelper encode:[post toJSON]]};
            NSString *sql = [SQLHelper buildReplaceSQL:ABUTableCache values:values];
            char *errMsg;
            if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"HomeDB Failed to updateCache %@", [NSString stringWithCString:errMsg]);
            }
        }
        sqlite3_exec(self.database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    }
}


@end
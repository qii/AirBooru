//
// Created by qii on 7/11/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "OpenSQLiteDatabase.h"
#import "FileHelper.h"
#import "SQLHelper.h"

static NSString *const TABLE_VERSION = @"version";
static NSString *const COLUMN_VERSION = @"version";

static int const VERSION_ZERO = 0;

@interface OpenSQLiteDatabase ()
@end

@implementation OpenSQLiteDatabase

- (BOOL)open:(NSString *)databaseFileName version:(int)version {
    if (version <= VERSION_ZERO) {
        NSLog(@"OpenSQLiteDatabase database version must bigger than 0");
        return NO;
    }
    NSString *databasePath = [FileHelper getExternalSupportFile:[NSString stringWithFormat:@"%@%@", databaseFileName, @".db"]];
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &_database) == SQLITE_OK) {
        self.open = YES;
        int dbVersion = [self getDBVersion];
        if (dbVersion != version) {
            if (dbVersion == VERSION_ZERO) {
                [self createVersionTable];
                [self databaseCreate];
            } else if (dbVersion < version) {
                [self databaseUpgrade:dbVersion newVersion:version];
            } else {
                [self databaseDowngrade:dbVersion newVersion:version];
            }
            [self setVersion:version];
        }
    } else {
        NSLog(@"OpenSQLiteDatabase failed to open/create database");
    }
    return YES;
}

- (void)close {
    sqlite3_close(self.database);
    self.open = NO;
}

#pragma mark - Database create, upgrade, downgrade

- (void)databaseCreate {
    NSLog(@"Subclass must implement databaseCreate");
}

- (void)databaseDowngrade:(int)currentVersion newVersion:(int)newVersion {
    NSLog(@"Subclass must implement databaseDowngrade");
}

- (void)databaseUpgrade:(int)currentVersion newVersion:(int)newVersion {
    NSLog(@"Subclass must implement databaseUpgrade");
}

#pragma mark - Database version

- (void)createVersionTable {
    NSDictionary *columns = @{
            COLUMN_VERSION : @"INTEGER PRIMARY KEY "};

    NSString *nodeSQL = [SQLHelper buildCreateTableSQL:TABLE_VERSION columns:columns];
    char *errMsg;
    if (sqlite3_exec(self.database, nodeSQL.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"OpenSQLiteDatabase failed to create version table %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
    }
}

- (void)setVersion:(int)version {
    NSString *sql = [SQLHelper buildDeleteAllSQL:TABLE_VERSION];
    char *errMsg;
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"OpenSQLiteDatabase failed to clear version data %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
    }

    NSDictionary *values = @{
            COLUMN_VERSION : @(version).stringValue,
    };
    sql = [SQLHelper buildReplaceSQL:TABLE_VERSION values:values];
    if (sqlite3_exec(self.database, sql.UTF8String, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"OpenSQLiteDatabase failed to setVersion %@", [NSString stringWithCString:errMsg encoding:NSUTF8StringEncoding]);
    }
}

- (int)getDBVersion {
    NSString *sql = [SQLHelper buildQuerySQL:TABLE_VERSION columns:@[COLUMN_VERSION] where:nil];
    const char *query_stmt = [sql UTF8String];
    sqlite3_stmt *queryStmt = nil;
    int version = VERSION_ZERO;
    if (sqlite3_prepare_v2(self.database, query_stmt, -1, &queryStmt, NULL) == SQLITE_OK) {
        if (sqlite3_step(queryStmt) == SQLITE_ROW) {
            version = sqlite3_column_int(queryStmt, 0);
        } else {
            NSLog(@"OpenSQLiteDatabase failed to getDBVersion %@", [NSString stringWithCString:sqlite3_errmsg(_database) encoding:NSUTF8StringEncoding]);
            version = VERSION_ZERO;
        }
    } else {
        NSLog(@"OpenSQLiteDatabase failed to getDBVersion %@", [NSString stringWithCString:sqlite3_errmsg(_database) encoding:NSUTF8StringEncoding]);
    }
    sqlite3_finalize(queryStmt);
    return version;
}

@end
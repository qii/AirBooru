//
// Created by qii on 3/10/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import "SQLHelper.h"


@implementation SQLHelper

+ (NSString *)buildCreateTableSQL:(NSString *)tableName columns:(NSDictionary *)columns {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"CREATE TABLE IF NOT EXISTS "];
    [sql appendString:tableName];
    [sql appendString:@"("];
    NSArray *keys = columns.allKeys;
    int count = keys.count;
    for (int i = 0; i < count; i++) {
        NSString *key = keys[i];
        [sql appendString:key];
        [sql appendString:@" "];
        [sql appendString:columns[key]];
        if (i < count - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];
    return sql;
}

+ (NSString *)buildDropTableSQL:(NSString *)tableName {
    return [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
}

+ (NSString *)buildDeleteSQL:(NSString *)tableName where:(NSDictionary *)where {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"DELETE FROM "];
    [sql appendString:tableName];
    [sql appendString:@" WHERE "];
    if (where.count == 1) {
        [sql appendString:where.allKeys.firstObject];
        [sql appendString:@"="];
        [sql appendString:[NSString stringWithFormat:@"\"%@\"", where.allValues.firstObject]];
    } else {
        NSArray *keys = where.allKeys;
        int count = keys.count;
        for (int i = 0; i < count; i++) {
            NSString *key = keys[i];
            NSString *value = [NSString stringWithFormat:@"\"%@\"", where[key]];
            [sql appendString:key];
            [sql appendString:@"="];
            [sql appendString:value];
            if (i < count - 1) {
                [sql appendString:@" AND "];
            }
        }
    }
    return sql;
}

+ (NSString *)buildDeleteLikeSQL:(NSString *)tableName where:(NSDictionary *)where {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"DELETE FROM "];
    [sql appendString:tableName];
    [sql appendString:@" WHERE "];
    [sql appendString:where.allKeys.firstObject];
    [sql appendString:@" LIKE "];
    [sql appendString:[NSString stringWithFormat:@"\"%@\"", where.allValues.firstObject]];
    return sql;
}

+ (NSString *)buildQuerySQL:(NSString *)tableName columns:(NSArray *)columns where:(NSDictionary *)where {
    return [SQLHelper buildQuerySQL:tableName columns:columns where:where order:nil];
}

+ (NSString *)buildQuerySQL:(NSString *)tableName columns:(NSArray *)columns where:(NSDictionary *)where order:(NSString *)order {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT  "];
    int columnsCount = columns.count;
    for (int i = 0; i < columnsCount; i++) {
        NSString *column = columns[i];
        [sql appendString:@" "];
        [sql appendString:column];
        if (i < columnsCount - 1) {
            [sql appendString:@","];
        }
    }

    [sql appendString:@" FROM "];
    [sql appendString:tableName];
    if (where != nil) {
        [sql appendString:@" WHERE "];
        if (where.count == 1) {
            [sql appendString:where.allKeys.firstObject];
            [sql appendString:@"="];
            [sql appendString:[NSString stringWithFormat:@"\"%@\"", where.allValues.firstObject]];
        } else {
            NSArray *keys = where.allKeys;
            int count = keys.count;
            for (int i = 0; i < count; i++) {
                NSString *key = keys[i];
                NSString *value = [NSString stringWithFormat:@"\"%@\"", where[key]];
                [sql appendString:key];
                [sql appendString:@"="];
                [sql appendString:value];
                if (i < count - 1) {
                    [sql appendString:@" AND "];
                }
            }
        }
    }
    if (order != nil) {
        [sql appendString:@" ORDER BY "];
        [sql appendString:order];
    }
    return sql;
}

+ (NSString *)buildUpdateSQL:(NSString *)tableName values:(NSDictionary *)values where:(NSDictionary *)where {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"UPDATE  "];
    [sql appendString:tableName];
    [sql appendString:@" SET  "];

    NSArray *valuesKeys = values.allKeys;
    int valuesCount = valuesKeys.count;
    for (int i = 0; i < valuesCount; i++) {
        NSString *key = valuesKeys[i];
        NSString *value = [NSString stringWithFormat:@"\"%@\"", values[key]];
        [sql appendString:key];
        [sql appendString:@"="];
        [sql appendString:value];
        if (i < valuesCount - 1) {
            [sql appendString:@","];
        }
    }

    [sql appendString:@" WHERE "];
    if (where.count == 1) {
        [sql appendString:where.allKeys.firstObject];
        [sql appendString:@"="];
        [sql appendString:[NSString stringWithFormat:@"\"%@\"", where.allValues.firstObject]];
    } else {
        NSArray *keys = where.allKeys;
        int count = keys.count;
        for (int i = 0; i < count; i++) {
            NSString *key = keys[i];
            NSString *value = [NSString stringWithFormat:@"\"%@\"", where[key]];
            [sql appendString:key];
            [sql appendString:@"="];
            [sql appendString:value];
            if (i < count - 1) {
                [sql appendString:@" AND "];
            }
        }
    }
    return sql;
}

+ (NSString *)buildReplaceSQL:(NSString *)tableName values:(NSDictionary *)values {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"REPLACE INTO  "];
    [sql appendString:tableName];

    [sql appendString:@"(  "];
    NSArray *keys = values.allKeys;
    int count = values.count;
    for (int i = 0; i < count; i++) {
        NSString *key = keys[i];
        [sql appendString:key];
        if (i < count - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@") VALUES ("];
    for (int i = 0; i < count; i++) {
        NSString *key = keys[i];
        NSString *value = [NSString stringWithFormat:@"\"%@\"", values[key]];
        [sql appendString:value];
        if (i < count - 1) {
            [sql appendString:@","];
        }
    }
    [sql appendString:@")"];
    return sql;
}

+ (NSString *)buildSumSQL:(NSString *)tableName column:(NSString *)column {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"SELECT SUM("];
    [sql appendString:column];
    [sql appendString:@") FROM "];
    [sql appendString:tableName];
    return sql;
}

+ (NSString *)buildDeleteAllSQL:(NSString *)tableName {
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"DELETE FROM "];
    [sql appendString:tableName];
    return sql;
}

@end
//
// Created by qii on 3/10/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SQLHelper : NSObject
+ (NSString *)buildCreateTableSQL:(NSString *)tableName columns:(NSDictionary *)columns;

+ (NSString *)buildDropTableSQL:(NSString *)tableName;

+ (NSString *)buildDeleteSQL:(NSString *)tableName where:(NSDictionary *)where;

+ (NSString *)buildDeleteLikeSQL:(NSString *)tableName where:(NSDictionary *)where;

+ (NSString *)buildQuerySQL:(NSString *)tableName columns:(NSArray *)columns where:(NSDictionary *)where;

+ (NSString *)buildQuerySQL:(NSString *)tableName columns:(NSArray *)columns where:(NSDictionary *)where order:(NSString *)order;

+ (NSString *)buildUpdateSQL:(NSString *)tableName values:(NSDictionary *)values where:(NSDictionary *)where;

+ (NSString *)buildReplaceSQL:(NSString *)tableName values:(NSDictionary *)values;

+ (NSString *)buildSumSQL:(NSString *)tableName column:(NSString *)column;

+ (NSString *)buildDeleteAllSQL:(NSString *)tableName;

@end
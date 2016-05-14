//
// Created by qii on 7/11/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface OpenSQLiteDatabase : NSObject
@property(assign, nonatomic) sqlite3 *database;
@property(nonatomic, assign, getter=isOpen) BOOL open;

- (BOOL)open:(NSString *)databaseFileName version:(int)version;

- (void)close;

- (void)databaseCreate;

- (void)databaseDowngrade:(int)currentVersion newVersion:(int)newVersion;

- (void)databaseUpgrade:(int)currentVersion newVersion:(int)newVersion;

@end
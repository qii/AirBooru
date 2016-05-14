//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LocalCacheManager.h"
#import "LocalCacheDB.h"

@interface LocalCacheManager ()
@property(strong, nonatomic) NSMutableDictionary *dbDictionary;
@end

@implementation LocalCacheManager

+ (instancetype)sharedInstance {
    static LocalCacheManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[LocalCacheManager alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dbDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (LocalCacheDB *)getCacheDB:(NSString *)serverName {
    @synchronized (self) {
        LocalCacheDB *db = self.dbDictionary[serverName];
        if (db == nil) {
            db = [[LocalCacheDB alloc] init];
            self.dbDictionary[serverName] = db;
        }
        return db;
    }
    return nil;
}


@end
//
// Created by qii on 7/13/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ServersManager.h"
#import "ImageBoard2.h"
#import "Konachan.h"

static NSString *const UserDefaultsName = @"Servers";

@interface ServersManager ()
@property(nonatomic, strong) NSMutableArray *blockArray;
@end

@implementation ServersManager

+ (instancetype)sharedInstance {
    static ServersManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.blockArray = [[NSMutableArray alloc] init];
        [self loadImageBoards];
    }
    return self;
}

- (void)loadImageBoards {
    self.imageBoardArray = [[NSMutableArray alloc] init];

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:UserDefaultsName];
    if (![defaults arrayForKey:@"servers"]) {
        NSDictionary *appDefaultServer = @{@"url" : @"https://yande.re", @"isUserConfig" : @NO};
        [defaults setObject:@[appDefaultServer] forKey:@"servers"];
        [defaults synchronize];
    }

    NSArray *servers = [defaults arrayForKey:@"servers"];
    for (NSDictionary *server in servers) {
        NSString *url = server[@"url"];
        BOOL isUserConfig = ((NSNumber *) server[@"isUserConfig"]).boolValue;
        [self.imageBoardArray addObject:[Danbooru danbooruWithURL:url isUserConfig:isUserConfig]];
    }
    self.imageBoard = self.imageBoardArray[0];
}

- (BOOL)addServer:(NSString *)url error:(NSError **)outError {
    Danbooru *danbooru = [Danbooru danbooruWithURL:url isUserConfig:YES];
    if (![self.imageBoardArray containsObject:danbooru]) {
        [self.imageBoardArray addObject:danbooru];
        [self saveToUserDefaults];
        return YES;
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Server is already exist"};
        *outError = [NSError errorWithDomain:ABUErrorDomain code:ABUDatabaseError userInfo:userInfo];
        return NO;
    }
}

- (void)deleteServer:(Danbooru *)server {
    [self.imageBoardArray removeObject:server];
    [self saveToUserDefaults];
}

- (void)saveToUserDefaults {
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    for (Danbooru *danbooru in self.imageBoardArray) {
        NSString *url = danbooru.url;
        BOOL isUserConfig = danbooru.isUserConfig;
        [servers addObject:@{@"url" : url, @"isUserConfig" : @(isUserConfig)}];
    }
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:UserDefaultsName];
    [defaults setObject:servers forKey:@"servers"];
    [defaults synchronize];
}

- (void)addImageBoardChangedBlock:(ABUServersManagerImageBoardChangeBlock)changeBlock {
    [self.blockArray addObject:changeBlock];
}

- (void)setImageBoard:(ImageBoard2 *)imageBoard {
    _imageBoard = imageBoard;
    for (ABUServersManagerImageBoardChangeBlock block in self.blockArray) {
        block(_imageBoard);
    }
}

@end
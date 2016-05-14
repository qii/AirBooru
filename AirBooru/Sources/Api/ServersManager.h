//
// Created by qii on 7/13/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Danbooru.h"

@class ImageBoard2;

static NSString *const ABUErrorDomain = @"ABUErrorDomain";
enum ABUError {
    ABUDatabaseError = 0,
};

typedef void (^ABUServersManagerImageBoardChangeBlock)(ImageBoard2 *imageBoard);

@interface ServersManager : NSObject
@property(nonatomic, strong) NSMutableArray *imageBoardArray;
@property(nonatomic, strong) Danbooru *imageBoard;

+ (instancetype)sharedInstance;

- (BOOL)addServer:(NSString *)url error:(NSError **)outError;

- (void)deleteServer:(Danbooru *)server;

- (void)addImageBoardChangedBlock:(ABUServersManagerImageBoardChangeBlock)changeBlock;
@end
//
// Created by qii on 5/1/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "NetworkOperation.h"
#import "UIHelper.h"
#import "FileHelper.h"
#import "AFHTTPRequestOperation.h"
#import "AppHttpClient.h"
#import "LocalCacheDB.h"
#import "LocalCacheManager.h"
#import "ImageLoaderOption.h"

@interface NetworkOperation ()
@property(assign, nonatomic) float percent;
@end

@implementation NetworkOperation

+ (instancetype)operationWithUrl:(NSString *)url {
    NetworkOperation *operation = [[NetworkOperation alloc] init];
    operation.url = url;
    operation.percent = 0.0f;
    return operation;
}

- (void)addOption:(ImageLoaderOption *)option {
    [super addOption:option];
    option.percentBlock(self.url, self.percent);
}

- (void)addOptions:(NSArray *)options {
    [super addOptions:options];
    for (ImageLoaderOption *option in options) {
        option.percentBlock(self.url, self.percent);
    }
}

- (void)main {
    NSString *extension = self.url.pathExtension;
    NSString *timestamp = [UIHelper timestampString];
    NSString *fileName = [NSString stringWithFormat:@"%02x_%02x.%@", self.url.hash, timestamp.intValue, extension];
    NSString *tmpFile = [FileHelper getExternalTempFile:fileName];

    NSError *resultError = nil;
    for (int i = 0; i < 2; i++) {
        NSError *error = nil;
        [self downloadFileToLocation:tmpFile error:&error];
        if (error != nil) {
            self.percent = 0;
            resultError = error;
        } else {
            resultError = nil;
            break;
        }
    }

    if (resultError != nil) {
        if (self.resultBlock != nil) {
            self.resultBlock(NO, nil);
        }
    } else {
        NSString *cacheFile = [FileHelper getExternalCacheFile:fileName createIfNotExsit:NO];
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:tmpFile toPath:cacheFile error:&error];
        LocalCacheDB *db = [[LocalCacheManager sharedInstance] getCacheDB:@"yande"];
        [db updateCache:self.url file:cacheFile];

        if (self.resultBlock != nil) {
            self.resultBlock(YES, cacheFile);
        }
    }
}

- (void)downloadFileToLocation:(NSString *)tmpFile error:(NSError **)error {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block volatile NSError *resultError = nil;
    AFHTTPRequestOperation *task = [[AppHttpClient sharedInstance] downloadFile:[[NSURL alloc] initWithString:self.url]
                                                                     toLocation:tmpFile
                                                                        headers:nil
                                                                   percentBlock:^(NSString *url, float percent) {
                                                                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                           self.percent = percent;
                                                                           NSArray *array = [self allOptions];
                                                                           for (ImageLoaderOption *option in array) {
                                                                               option.percentBlock(url, percent);
                                                                           }
                                                                       }];
                                                                   } completeBlock:^(NSString *string, NSError *error) {
                resultError = error;
                dispatch_semaphore_signal(semaphore);
            }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (resultError != nil) {
        *error = resultError;
        [FileHelper deleteFile:tmpFile];
    }
}

@end
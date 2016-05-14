//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "AppHttpClient.h"
#import "AFHTTPRequestOperation.h"


@implementation AppHttpClient

+ (instancetype)sharedInstance {
    static AppHttpClient *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[AppHttpClient alloc] init];
    });
    return singleton;
}

- (AFHTTPRequestOperation *)downloadFile:(NSURL *)url toLocation:(NSString *)location headers:(NSDictionary *)headers percentBlock:(AppHttpClientPercentBlock)percentBlock completeBlock:(AppHttpClientCompleteBlock)completeBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (headers != nil) {
        NSArray *keys = headers.allKeys;
        for (NSString *key in keys) {
            NSString *value = headers[key];
            [request setValue:value forHTTPHeaderField:key];
        }
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:location]) {
        NSError *error = nil;
        [fileManager createFileAtPath:location contents:[NSData data] attributes:nil];
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:location append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float percent = (float) ((double) totalBytesRead / (double) totalBytesExpectedToRead);
        percentBlock(url.absoluteString, percent);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSHTTPURLResponse *response = operation.response;
        int code = response.statusCode;
        completeBlock((NSString *) responseObject, nil);
    }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        AppLog(@"ERR: %@", [error description]);
        completeBlock(nil, error);
    }];
    [operation start];
    return operation;
}

- (NSString *)doGet:(NSString *)url error:(NSError **)error {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    request.HTTPMethod = @"Get";

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block volatile NSString *result = nil;
    __block volatile NSError *resultError = nil;
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        resultError = error;
        dispatch_semaphore_signal(sem);
        [session finishTasksAndInvalidate];
    }];
    [postDataTask resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    *error = resultError;
    return result;
}

@end
//
// Created by qii on 3/4/15.
// Copyright (c) 2015 QuickPic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UrlHelper : NSObject
+ (NSString *)encode:(NSString *)value;

+ (NSString *)decode:(NSString *)value;

+ (NSString *)buildUrlString:(NSString *)url params:(NSDictionary *)params;

+ (NSURL *)buildUrl:(NSString *)url params:(NSDictionary *)params;

+ (BOOL) validateUrl: (NSString *) candidate;
@end
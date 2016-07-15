//
// Created by qii on 3/4/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "UrlHelper.h"


@implementation UrlHelper

+ (NSString *)encode:(NSString *)value {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) value,
            NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

+ (NSString *)decode:(NSString *)value {
    return [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)buildUrlString:(NSString *)url params:(NSDictionary *)params {
    NSMutableString *result = [[NSMutableString alloc] initWithString:url];
    NSArray *keys = params.allKeys;
    BOOL first = YES;
    for (NSString *key in keys) {
        if (first) {
            [result appendString:@"?"];
            first = NO;
        } else {
            [result appendString:@"&"];
        }
        [result appendString:key];
        [result appendString:@"="];
        [result appendString:[UrlHelper encode:params[key]]];
    }
    return result;
}

+ (NSURL *)buildUrl:(NSString *)url params:(NSDictionary *)params {
    return [[NSURL alloc] initWithString:[UrlHelper buildUrlString:url params:params]];
}

+ (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
            @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}
@end
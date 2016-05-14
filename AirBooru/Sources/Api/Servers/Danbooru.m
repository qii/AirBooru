//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Danbooru.h"
#import "PostList.h"
#import "UrlHelper.h"
#import "AppHttpClient.h"
#import "TagList.h"

@interface Danbooru ()
@end

@implementation Danbooru

+ (instancetype)danbooruWithURL:(NSString *)url isUserConfig:(BOOL)isUserConfig {
    Danbooru *danbooru = [[Danbooru alloc] init];
    danbooru.url = url;
    danbooru.userConfig = isUserConfig;
    return danbooru;
}

- (NSString *)identifyId {
    NSString *stringId = [NSString stringWithFormat:@"%@_%d", self.url, self.isUserConfig];
    NSString *hex = [NSString stringWithFormat:@"%02x", stringId.hash];
    return hex;
}

- (NSString *)hostAddress {
    return self.url;
}

- (NSString *)name {
    if (self.isUserConfig) {
        return [[NSURL alloc] initWithString:self.hostAddress].host;
    } else {
        return @"default";
    }
}

- (PostList *)queryPostList:(int)page limit:(int)limit tags:(NSArray *)tags error:(NSError **)outError {
    NSDictionary *params;
    if (tags) {
        params = @{@"page" : @(page).stringValue,
                @"limit" : @(limit).stringValue,
                @"tags" : tags[0]};
    } else {
        params = @{@"page" : @(page).stringValue,
                @"limit" : @(limit).stringValue};
    }
    if (!self.isUserConfig) {
        NSMutableDictionary *safe = [NSMutableDictionary dictionaryWithDictionary:params];
        safe[@"limit"] = @(limit * 2).stringValue;
        params = [NSDictionary dictionaryWithDictionary:safe];
    }
    NSString *host = [NSString stringWithFormat:@"%@%@", [self hostAddress], @"/post.json"];
    NSString *url = [UrlHelper buildUrlString:host params:params];

    NSError *error = nil;
    NSString *result = [[AppHttpClient sharedInstance] doGet:url error:&error];
    if (error != nil) {
        *outError = error;
        return nil;
    } else {
        PostList *list = [PostList parseJson:result isUserConfig:self.isUserConfig];
        return list;
    }
}

- (TagList *)queryTagList:(int)page limit:(int)limit name:(NSString *)name error:(NSError **)outError {
    NSDictionary *params;
    if (name) {
        params = @{@"page" : @(page).stringValue,
                @"limit" : @(limit).stringValue,
                @"order" : @"count",
                @"name" : name};
    } else {
        params = @{@"page" : @(page).stringValue,
                @"limit" : @(limit).stringValue,
                @"order" : @"count"};
    }
    NSString *host = [NSString stringWithFormat:@"%@%@", [self hostAddress], @"/tag.json"];
    NSString *url = [UrlHelper buildUrlString:host params:params];

    NSError *error = nil;
    NSString *result = [[AppHttpClient sharedInstance] doGet:url error:&error];
    if (error != nil) {
        *outError = error;
        return nil;
    } else {
        TagList *list = [TagList parseJson:result isUserConfig:self.isUserConfig];
        return list;
    }
}

- (PostList *)queryPopularPostList:(int)page limit:(int)limit period:(NSString *)period error:(NSError **)outError {
    NSDictionary *params;
    if (period) {
        params = @{@"page" : @(page).stringValue,
                @"limit" : @(limit).stringValue,
                @"period" : period};
    } else {
        params = @{@"page" : @(page).stringValue,
                @"limit" : @(limit).stringValue};
    }
    NSString *host = [NSString stringWithFormat:@"%@%@", [self hostAddress], @"/post/popular_recent.json"];
    NSString *url = [UrlHelper buildUrlString:host params:params];

    NSError *error = nil;
    NSString *result = [[AppHttpClient sharedInstance] doGet:url error:&error];
    if (error != nil) {
        *outError = error;
        return nil;
    } else {
        PostList *list = [PostList parseJson:result isUserConfig:self.isUserConfig];
        return list;
    }
}

- (NSUInteger)hash {
    return _url.hash + @(self.isUserConfig).hash;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    Danbooru *otherDanbooru = (Danbooru *) other;
    return [self.url isEqualToString:otherDanbooru.url] && self.isUserConfig == otherDanbooru.isUserConfig;
}

@end
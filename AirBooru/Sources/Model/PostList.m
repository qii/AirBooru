//
// Created by qii on 4/24/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PostList.h"
#import "Post.h"


@implementation PostList

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

+ (instancetype)parseJson:(NSString *)json isUserConfig:(BOOL)isUserConfig {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:
            data                                     options:NSJSONReadingMutableContainers error:&error];

    NSArray *jsonPosts = (NSArray *) jsonObjects;
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    for (NSDictionary *jsonPost in jsonPosts) {
        Post *post = [Post parseJSON:jsonPost];
        if (isUserConfig) {
            [posts addObject:post];
        } else if ([post isStoreSafe]) {
            [posts addObject:post];
        }
    }

    PostList *list = [[PostList alloc] init];
    list.posts = [NSArray arrayWithArray:posts];
    return list;
}

+ (instancetype)parseJsonGelbooru:(NSString *)url json:(NSString *)json isUserConfig:(BOOL)isUserConfig {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:
            data                                     options:NSJSONReadingMutableContainers error:&error];

    NSArray *jsonPosts = (NSArray *) jsonObjects;
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    for (NSDictionary *jsonPost in jsonPosts) {
        Post *post = [Post parseJSONGelbooruUrl:url jsonObjects:jsonPost];
        if (isUserConfig) {
            [posts addObject:post];
        } else if ([post isStoreSafe]) {
            [posts addObject:post];
        }
    }

    PostList *list = [[PostList alloc] init];
    list.posts = [NSArray arrayWithArray:posts];
    return list;
}

- (Post *)getPostAt:(int)index {
    return self.posts[index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return self.posts[index];
}

- (void)addPosts:(NSArray *)posts {
    NSMutableArray *previousData = [NSMutableArray arrayWithArray:self.posts];
    [previousData addObjectsFromArray:posts];
    self.posts = [NSArray arrayWithArray:previousData];
}

- (int)count {
    return self.posts.count;
}

@end
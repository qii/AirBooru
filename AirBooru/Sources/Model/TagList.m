//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "TagList.h"
#import "Tag.h"


@implementation TagList

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

    NSArray *jsonTags = (NSArray *) jsonObjects;
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for (NSDictionary *jsonPost in jsonTags) {
        Tag *tag = [Tag parseJson:jsonPost];
        if (isUserConfig) {
            [tags addObject:tag];
        } else if ([tag isStoreSafe]) {
            [tags addObject:tag];
        }
    }

    TagList *list = [[TagList alloc] init];
    list.tags = [NSArray arrayWithArray:tags];
    return list;
}

//+ (instancetype)parseJsonGelbooru:(NSString *)url json:(NSString *)json {
//    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error = nil;
//    id jsonObjects = [NSJSONSerialization JSONObjectWithData:
//            data                                     options:NSJSONReadingMutableContainers error:&error];
//
//    NSArray *jsonPosts = (NSArray *) jsonObjects;
//    NSMutableArray *tags = [[NSMutableArray alloc] init];
//    for (NSDictionary *jsonPost in jsonPosts) {
//        Tag *tag = [Tag parseJsonGelbooruUrl:url jsonObjects:jsonPost];
//        [tags addObject:tag];
//    }
//
//    TagList *list = [[TagList alloc] init];
//    list.tags = [NSArray arrayWithArray:tags];
//    return list;
//}

- (Tag *)getTagAt:(int)index {
    return self.tags[index];
}

- (void)addTags:(NSArray *)posts {
    NSMutableArray *previousData = [NSMutableArray arrayWithArray:self.tags];
    [previousData addObjectsFromArray:posts];
    self.tags = [NSArray arrayWithArray:previousData];
}

@end
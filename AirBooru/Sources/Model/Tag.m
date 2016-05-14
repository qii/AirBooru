//
// Created by qii on 7/5/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Tag.h"
#import "StoreSafe.h"


@implementation Tag

+ (instancetype)parseJson:(NSDictionary *)jsonObjects {
    Tag *tag = [[Tag alloc] init];
    tag.tagId = ((NSNumber *) jsonObjects[@"id"]).longLongValue;
    tag.name = (NSString *) jsonObjects[@"name"];
    tag.count = ((NSNumber *) jsonObjects[@"count"]).longLongValue;
    tag.type = ((NSNumber *) jsonObjects[@"type"]).intValue;
    tag.ambiguous = ((NSNumber *) jsonObjects[@"ambiguous"]).boolValue;
    return tag;
}

- (BOOL)isStoreSafe {
    NSArray *words = [StoreSafe dangerousTags];
    for (NSString *word in words) {
        if ([self.name isEqualToString:word]) {
            return NO;
        }
    }
    return YES;
}

@end
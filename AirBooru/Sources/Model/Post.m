//
// Created by qii on 4/24/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Post.h"
#import "NSDictionary+NotNullKey.h"
#import "StoreSafe.h"


@implementation Post

+ (instancetype)parseJSON:(NSDictionary *)jsonObjects {
    Post *post = [[Post alloc] init];
    post.postId = ((NSNumber *) [jsonObjects objectForSafeKey:@"id"]).longLongValue;
    NSString *tags = [jsonObjects objectForSafeKey:@"tags"];
    if (tags != nil) {
        post.tags = [tags componentsSeparatedByString:@" "];
    }

    post.created_at = ((NSNumber *) [jsonObjects objectForSafeKey:@"created_at"]).longLongValue;
    post.created_id = ((NSNumber *) [jsonObjects objectForSafeKey:@"created_id"]).longLongValue;
    post.author = [jsonObjects objectForSafeKey:@"author"];
    post.change = ((NSNumber *) [jsonObjects objectForSafeKey:@"change"]).longLongValue;
    post.source = [jsonObjects objectForSafeKey:@"source"];
    post.score = ((NSNumber *) [jsonObjects objectForSafeKey:@"score"]).intValue;
    post.md5 = [jsonObjects objectForSafeKey:@"md5"];

    post.file_size = ((NSNumber *) [jsonObjects objectForSafeKey:@"file_size"]).longLongValue;
    post.file_url = [jsonObjects objectForSafeKey:@"file_url"];

    post.is_shown_in_index = ((NSNumber *) [jsonObjects objectForSafeKey:@"is_shown_in_index"]).boolValue;

    post.preview_url = [jsonObjects objectForSafeKey:@"preview_url"];
    post.preview_width = ((NSNumber *) [jsonObjects objectForSafeKey:@"preview_width"]).intValue;
    post.preview_height = ((NSNumber *) [jsonObjects objectForSafeKey:@"preview_height"]).intValue;

    post.actual_preview_width = ((NSNumber *) [jsonObjects objectForSafeKey:@"actual_preview_width"]).intValue;
    post.actual_preview_height = ((NSNumber *) [jsonObjects objectForSafeKey:@"actual_preview_height"]).intValue;

    post.sample_url = [jsonObjects objectForSafeKey:@"sample_url"];
    post.sample_width = ((NSNumber *) [jsonObjects objectForSafeKey:@"sample_width"]).intValue;
    post.sample_height = ((NSNumber *) [jsonObjects objectForSafeKey:@"sample_height"]).intValue;
    post.sample_file_size = ((NSNumber *) [jsonObjects objectForSafeKey:@"sample_file_size"]).longLongValue;

    post.jpeg_url = [jsonObjects objectForSafeKey:@"jpeg_url"];
    post.jpeg_width = ((NSNumber *) [jsonObjects objectForSafeKey:@"jpeg_width"]).intValue;
    post.jpeg_height = ((NSNumber *) [jsonObjects objectForSafeKey:@"jpeg_height"]).intValue;
    post.jpeg_file_size = ((NSNumber *) [jsonObjects objectForSafeKey:@"jpeg_file_size"]).longLongValue;

    post.rating = [jsonObjects objectForSafeKey:@"rating"];
    post.has_children = ((NSNumber *) [jsonObjects objectForSafeKey:@"has_children"]).boolValue;
    post.parent_id = [jsonObjects objectForSafeKey:@"id"];
    post.status = [jsonObjects objectForSafeKey:@"status"];
    post.width = ((NSNumber *) [jsonObjects objectForSafeKey:@"width"]).intValue;
    post.height = ((NSNumber *) [jsonObjects objectForSafeKey:@"height"]).intValue;
    post.is_held = ((NSNumber *) [jsonObjects objectForSafeKey:@"is_held"]).boolValue;
    return post;
}
//directory: "1457",
//hash: "ffcb4a966f42def62576423b48f9c40e",

//!id: 1526340
//image: "de6be0b45814eb2ea2f2b262dee6a544350481cd.jpg",
//!change: 1435654847,
//!owner: "danbooru",
//parent_id: 0,
//rating: "safe",

//width: 2893
//height: 4092,

//sample: true,
//sample_height: 1202,
//sample_width: 850,

//!score: 0,
//!tags: "2girls absurdres closed_eyes gloves hand_on_another's_shoulder headgear highres kantai_collection lineart long_hair looking_at_viewer midriff monochrome multiple_girls mutsu_(kantai_collection) nagato_(kantai_collection) navel short_hair yuki_(sonma_1426)",


// file_url="  http://safebooru.org/images/1457/a72d0a4123577618a796390470254d7ed8416cff.jpg"
// sample_url="http://safebooru.org/images/1457/a72d0a4123577618a796390470254d7ed8416cff.jpg"
// preview_url="http://safebooru.org/thumbnails/1457/thumbnail_a72d0a4123577618a796390470254d7ed8416cff.jpg"

+ (instancetype)parseJSONGelbooruUrl:(NSString *)url jsonObjects:(NSDictionary *)jsonObjects {
    Post *post = [[Post alloc] init];

    post.postId = ((NSNumber *) [jsonObjects objectForSafeKey:@"id"]).longLongValue;
    NSString *tags = [jsonObjects objectForSafeKey:@"tags"];
    if (tags != nil) {
        post.tags = [tags componentsSeparatedByString:@" "];
    }

    post.author = [jsonObjects objectForSafeKey:@"owner"];
    post.change = ((NSNumber *) [jsonObjects objectForSafeKey:@"change"]).longLongValue;
    post.score = ((NSNumber *) [jsonObjects objectForSafeKey:@"score"]).intValue;

    NSString *directory = (NSString *) [jsonObjects objectForSafeKey:@"directory"];
    NSString *image = (NSString *) [jsonObjects objectForSafeKey:@"image"];

    post.file_url = [NSString stringWithFormat:@"%@/images/%@/%@", url, directory, image];
    post.width = ((NSNumber *) [jsonObjects objectForSafeKey:@"width"]).intValue;
    post.height = ((NSNumber *) [jsonObjects objectForSafeKey:@"height"]).intValue;

    post.preview_url = [NSString stringWithFormat:@"%@/thumbnails/%@/thumbnail_%@", url, directory, image];

    BOOL sample = ((NSNumber *) [jsonObjects objectForSafeKey:@"sample"]).boolValue;
    if (sample) {
        post.sample_url = [NSString stringWithFormat:@"%@/samples/%@/sample_%@", url, directory, image];
        post.sample_width = ((NSNumber *) [jsonObjects objectForSafeKey:@"sample_width"]).intValue;
        post.sample_height = ((NSNumber *) [jsonObjects objectForSafeKey:@"sample_height"]).intValue;
    } else {
        post.sample_url = post.file_url;
        post.sample_width = post.width;
        post.sample_height = post.height;
    }

    post.rating = [jsonObjects objectForSafeKey:@"rating"];
    post.parent_id = [jsonObjects objectForSafeKey:@"parent_id"];
    post.status = [jsonObjects objectForSafeKey:@"status"];
    return post;
}

- (NSString *)toJSON {
    NSDictionary *dict = @{@"id" : @(self.postId).stringValue ?: [NSNull null],
            //todo tags
            @"created_at" : @(self.created_at).stringValue ?: [NSNull null],
            @"created_id" : @(self.created_id).stringValue ?: [NSNull null],
            @"change" : @(self.change).stringValue ?: [NSNull null],
            @"source" : self.source ?: [NSNull null],
            @"score" : @(self.score).stringValue ?: [NSNull null],
            @"md5" : self.md5 ?: [NSNull null],
            @"file_size" : @(self.file_size).stringValue ?: [NSNull null],
            @"file_url" : self.file_url ?: [NSNull null],
            @"is_shown_in_index" : @(self.is_shown_in_index).stringValue ?: [NSNull null],
            @"preview_url" : self.preview_url ?: [NSNull null],
            @"preview_width" : @(self.preview_width).stringValue ?: [NSNull null],
            @"preview_height" : @(self.preview_height).stringValue ?: [NSNull null],
            @"actual_preview_width" : @(self.actual_preview_width).stringValue ?: [NSNull null],
            @"actual_preview_height" : @(self.actual_preview_height).stringValue ?: [NSNull null],
            @"sample_url" : self.sample_url ?: [NSNull null],
            @"sample_width" : @(self.sample_width).stringValue ?: [NSNull null],
            @"sample_height" : @(self.sample_height).stringValue ?: [NSNull null],
            @"sample_file_size" : @(self.sample_file_size).stringValue ?: [NSNull null],
            @"jpeg_url" : self.jpeg_url ?: [NSNull null],
            @"jpeg_width" : @(self.jpeg_width).stringValue ?: [NSNull null],
            @"jpeg_height" : @(self.jpeg_height).stringValue ?: [NSNull null],
            @"jpeg_file_size" : @(self.jpeg_file_size).stringValue ?: [NSNull null],
            @"rating" : self.rating ?: [NSNull null],
            @"width" : @(self.width).stringValue ?: [NSNull null],
            @"height" : @(self.height).stringValue ?: [NSNull null],
            @"is_held" : @(self.is_held).stringValue};

    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (BOOL)isSafe {
    return self.rating && ([self.rating isEqualToString:@"s"] || [self.rating isEqualToString:@"safe"]);
}

- (BOOL)isStoreSafe {
    if ([[StoreSafe dangerousIds] containsObject:@(self.postId)]) {
        return NO;
    }
    if (self.tags) {
        NSArray *words = [StoreSafe dangerousTags];
        for (NSString *word in words) {
            if ([self.tags containsObject:word]) {
                return NO;
            }
        }
    }
    return [self isSafe];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    Post *target = (Post *) other;
    return self.postId == target.postId;
}

- (NSUInteger)hash {
    return @(self.postId).hash;
}

@end
//
// Created by qii on 4/24/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Post : NSObject
@property(nonatomic, assign) long long postId;
@property(nonatomic, strong) NSArray *tags;
@property(nonatomic, assign) long long created_at;
@property(nonatomic, assign) long long created_id;
@property(nonatomic, copy) NSString *author;
@property(nonatomic, assign) long long change;
@property(nonatomic, copy) NSString *source;
@property(nonatomic, assign) int score;
@property(nonatomic, copy) NSString *md5;
@property(nonatomic, assign) long long file_size;
@property(nonatomic, copy) NSString *file_url;
@property(nonatomic, assign) BOOL is_shown_in_index;
@property(nonatomic, copy) NSString *preview_url;
@property(nonatomic, assign) int preview_width;
@property(nonatomic, assign) int preview_height;
@property(nonatomic, assign) int actual_preview_width;
@property(nonatomic, assign) int actual_preview_height;
@property(nonatomic, copy) NSString *sample_url;
@property(nonatomic, assign) int sample_width;
@property(nonatomic, assign) int sample_height;
@property(nonatomic, assign) long long sample_file_size;
@property(nonatomic, copy) NSString *jpeg_url;
@property(nonatomic, assign) int jpeg_width;
@property(nonatomic, assign) int jpeg_height;
@property(nonatomic, assign) long long jpeg_file_size;
@property(nonatomic, copy) NSString *rating;
@property(nonatomic, assign) BOOL has_children;
@property(nonatomic, copy) NSString *parent_id;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, assign) int width;
@property(nonatomic, assign) int height;
@property(nonatomic, assign) BOOL is_held;

+ (instancetype)parseJSON:(NSDictionary *)json;

+ (instancetype)parseJSONGelbooruUrl:(NSString *)url jsonObjects:(NSDictionary *)json;

- (NSString *)toJSON;

- (BOOL)isSafe;

- (BOOL)isStoreSafe;
@end
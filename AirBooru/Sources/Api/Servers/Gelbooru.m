//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Gelbooru.h"
#import "PostList.h"
#import "AppHttpClient.h"
#import "UrlHelper.h"


@implementation Gelbooru

- (NSString *)hostAddress {
    return nil;
}
//http://safebooru.org/index.php?page=dapi&s=post&q=index&limit=60&pid=0&json=1

//directory: "1457",
//hash: "ffcb4a966f42def62576423b48f9c40e",

//id: 1526340,
//image: "de6be0b45814eb2ea2f2b262dee6a544350481cd.jpg",
//change: 1435654847,
//owner: "danbooru",
//parent_id: 0,
//rating: "safe",

//width: 2893
//height: 4092,

//sample: true,
//sample_height: 1202,
//sample_width: 850,

//score: 0,
//tags: "2girls absurdres closed_eyes gloves hand_on_another's_shoulder headgear highres kantai_collection lineart long_hair looking_at_viewer midriff monochrome multiple_girls mutsu_(kantai_collection) nagato_(kantai_collection) navel short_hair yuki_(sonma_1426)",


//<post
// height="1000"
// width="700"
// score="0"
// file_url="http://safebooru.org/images/1457/a72d0a4123577618a796390470254d7ed8416cff.jpg"
// sample_url="http://safebooru.org/images/1457/a72d0a4123577618a796390470254d7ed8416cff.jpg"
// preview_url="http://safebooru.org/thumbnails/1457/thumbnail_a72d0a4123577618a796390470254d7ed8416cff.jpg"


// parent_id=""
// sample_width="700"
// sample_height="1000"
// rating="s"
// tags=" 1girl alternate_hairstyle arms_up bikini blonde_hair blue_sky bow clouds enjoy_mix fang hair_bow ibuki_suika long_sleeves navel oni_horns open_mouth ponytail red_eyes sky smile solo swimsuit touhou "
// id="1526367"
// change="1435658437"
// md5="673a4080c554a4ae7f40ff406c48ff3e"
// creator_id="168"
// has_children="false"
// created_at="Tue Jun 30 12:00:37 +0200 2015" status="active"
// source="http://i4.pixiv.net/img-original/img/2015/06/30/18/31/44/51168855_p0.jpg"
// has_notes="false"
// has_comments="false"
// preview_width="105"
// preview_height="150"/>

- (PostList *)queryPostList:(int)page limit:(int)limit tags:(NSArray *)tags error:(NSError **)outError {
    NSDictionary *params = @{@"page" : @"dapi",
            @"s" : @"post",
            @"q" : @"index",
            @"pid" : @(page).stringValue,
            @"limit" : @(limit).stringValue,
            @"json" : @"1"};
    NSString *host = [NSString stringWithFormat:@"%@%@", [self hostAddress], @"/index.php"];
    NSString *url = [UrlHelper buildUrlString:host params:params];
    NSError *error = nil;
    NSString *result = [[AppHttpClient sharedInstance] doGet:url error:&error];
    if (error != nil) {
        *outError = error;
        return nil;
    } else {
        PostList *list = [PostList parseJsonGelbooru:[self hostAddress] json:result isUserConfig:NO];
        return list;
    }
}

@end
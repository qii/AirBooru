//
// Created by qii on 6/30/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "Safebooru.h"
#import "PostList.h"
#import "AppHttpClient.h"
#import "UrlHelper.h"

static NSString *const BASE_URL = @"http://safebooru.org";

@implementation Safebooru

-(NSString *)hostAddress{
    return BASE_URL;
}

@end
//
// Created by qii on 4/26/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <objc/runtime.h>
#import "UIHelper.h"


@implementation UIHelper

+ (NSString *)timestampString {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = @(timeStamp);
    return timeStampObj.stringValue;
}

+ (void)UIShowNetworkIndicator:(BOOL)show {
    UIApplication *app = UIApplication.sharedApplication;
    const static void *kShowNetworkIndicatorKey = (const void *) @"UIShowNetworkIndicatorKey";
    unsigned int networkIndicatorRef = [objc_getAssociatedObject(app, kShowNetworkIndicatorKey) unsignedIntValue];
    if (show) {
        if (networkIndicatorRef == 0) app.networkActivityIndicatorVisible = YES;
        networkIndicatorRef++;
    }
    else {
        if (networkIndicatorRef != 0) networkIndicatorRef--;
        if (networkIndicatorRef == 0) app.networkActivityIndicatorVisible = NO;
    }
    objc_setAssociatedObject(app, kShowNetworkIndicatorKey, [NSNumber numberWithUnsignedInt:networkIndicatorRef], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
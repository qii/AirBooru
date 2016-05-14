//
// Created by qii on 5/12/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LogDeallocViewController.h"


@implementation LogDeallocViewController {

}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end
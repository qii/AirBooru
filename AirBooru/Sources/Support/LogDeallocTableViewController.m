//
// Created by qii on 5/12/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "LogDeallocTableViewController.h"


@implementation LogDeallocTableViewController {

}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end
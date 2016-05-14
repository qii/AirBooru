//
// Created by qii on 7/11/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SettingCell : UITableViewCell

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *rightTitle;
@property(nonatomic, assign, getter = isTop) BOOL top;
@property(nonatomic, assign, getter = isBottom) BOOL bottom;

@end
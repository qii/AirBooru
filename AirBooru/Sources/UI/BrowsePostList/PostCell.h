//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Post;

@interface PostCell : UICollectionViewCell
@property(nonatomic, getter=isEditing) BOOL editing;
@property(strong, nonatomic) Post *post;
@end
//
// Created by qii on 7/8/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class PostList;
@class ImageBoard2;

@interface PostListViewController : UIViewController
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) ImageBoard2 *imageBoard;
@property(nonatomic, strong) PostList *postList;
@property(nonatomic, assign) BOOL canLoadMore;
@property(nonatomic, strong) NSString *emptyTip;

- (void)loadLatestPostList;

- (void)loadPreviousPostList;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView didLongSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)beginRefreshing;

- (void)endRefreshing;

- (void)beginFooterRefreshing;

- (void)endFooterRefreshing;
@end
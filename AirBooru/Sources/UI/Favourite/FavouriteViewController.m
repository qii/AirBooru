//
// Created by qii on 7/9/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "FavouriteViewController.h"
#import "FavouriteDB.h"
#import "PostList.h"
#import "Post.h"
#import "PostCell.h"
#import "ThemeHelper.h"
#import "ToastView.h"

@interface FavouriteViewController ()
@property(nonatomic, strong) UIToolbar *toolbar;
@property(nonatomic, strong) NSMutableArray *selectedItemArray;
@end

@implementation FavouriteViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedItemArray = [[NSMutableArray alloc] init];
        self.emptyTip = @"No favourited post";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.collectionView.allowsMultipleSelection = YES;
    self.canLoadMore = NO;
}

- (void)loadLatestPostList {
    NSArray *array = [[FavouriteDB sharedInstance] query];
    self.postList = [[PostList alloc] init];
    self.postList.posts = array;
    [self.collectionView reloadData];
    [self endRefreshing];
}

- (void)loadPreviousPostList {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadLatestPostList];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!editing && self.selectedItemArray.count > 0) {
        for (NSIndexPath *path in self.selectedItemArray) {
            PostCell *cell = (PostCell *) [self.collectionView cellForItemAtIndexPath:path];
            cell.editing = NO;
            cell.selected = NO;
        }
        [self.selectedItemArray removeAllObjects];
        [self.collectionView reloadData];
    }

    if (editing) {
        self.tabBarController.tabBar.hidden = YES;
        [self addToolbar];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.tabBarController.tabBar.hidden = NO;
        [self.toolbar removeFromSuperview];
        self.toolbar = nil;
    }
}

- (void)addToolbar {
    self.toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
    self.toolbar.tintColor = [ThemeHelper tintColor];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:flexSpace];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectedItems)]];
    [items addObject:flexSpace];
    [self.toolbar setItems:items];
    [self.view addSubview:self.toolbar];
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
            UIInterfaceOrientationIsLandscape(orientation))
        height = 32;
    return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
}

- (void)deleteSelectedItems {
    if (self.selectedItemArray.count == 0) {
        [self setEditing:NO animated:YES];
        [ToastView toastWithTitle:@"Please select pictures"];
        return;
    }
    for (NSIndexPath *path in self.selectedItemArray) {
        Post *post = [self.postList getPostAt:path.row];
        FavouriteDB *favouriteDB = [FavouriteDB sharedInstance];
        [favouriteDB deletePost:post.postId];
    }
    [self setEditing:NO animated:YES];
    [self loadLatestPostList];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isEditing) {
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    } else {
        PostCell *cell = (PostCell *) [collectionView cellForItemAtIndexPath:indexPath];
        cell.editing = YES;
        cell.selected = YES;
        [self.selectedItemArray addObject:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        PostCell *cell = (PostCell *) [collectionView cellForItemAtIndexPath:indexPath];
        cell.editing = YES;
        cell.selected = NO;
        [self.selectedItemArray removeObject:indexPath];
    }
}

@end
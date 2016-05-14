//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "BrowsePostViewController.h"
#import "PostList.h"
#import "Post.h"
#import "ViewPager.h"
#import "ZoomScrollView.h"
#import "ImageLoader.h"
#import "BrowsePostCell.h"
#import "LocalCacheDB.h"
#import "LocalCacheManager.h"
#import "ToastView.h"
#import "SlideShowViewController.h"
#import "ThemeHelper.h"
#import "FavouriteDB.h"

@import Photos;

@interface BrowsePostViewController () <ViewPagerDelegate>
@property(strong, nonatomic) PostList *postList;
@property(assign, nonatomic) int index;

@property(strong, nonatomic) ViewPager *viewPager;
@property(copy, nonatomic) ZoomScrollSingleTapBlock zoomScrollSingleTapBlock;
@property(strong, nonatomic) UIView *currentItemView;
@property(assign, nonatomic) BOOL statusBarShouldBeHidden;
@property(strong, nonatomic) UIToolbar *toolbar;
@property(strong, nonatomic) UIButton *favButton;
@end

@implementation BrowsePostViewController
+ (instancetype)viewControllerWithPostList:(PostList *)postList index:(int)index {
    BrowsePostViewController *controller = [[BrowsePostViewController alloc] init];
    controller.postList = postList;
    controller.index = index;
    return controller;
}

- (id)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    UIBarButtonItem *playSlideShowButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(slideShow:)];
//    self.navigationItem.rightBarButtonItem = playSlideShowButton;
    self.toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
    self.toolbar.tintColor = [ThemeHelper tintColor];

    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action)]];
    [items addObject:flexSpace];

    {
        self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.favButton setShowsTouchWhenHighlighted:YES];
        [self.favButton addTarget:self action:@selector(fav) forControlEvents:UIControlEventTouchUpInside];
        [self.favButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_favoruite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.favButton setFrame:CGRectMake(280, 25, 30, 30)];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.favButton];
        [items addObject:barButtonItem];
    }

    [items addObject:flexSpace];

    UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
    [more setShowsTouchWhenHighlighted:YES];
    [more addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [more setBackgroundImage:[[UIImage imageNamed:@"toolbar_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [more setFrame:CGRectMake(280, 25, 30, 30)];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    [items addObject:barButtonItem];

    [self.toolbar setItems:items];
    [self.view addSubview:self.toolbar];

    [self.viewPager jumpToPageAtIndex:self.index animated:NO];
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
            UIInterfaceOrientationIsLandscape(orientation))
        height = 32;
    return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
}

- (void)loadView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    view.backgroundColor = [UIColor blackColor];

    self.view = view;

    __weak BrowsePostViewController *weakSelf = self;
    self.zoomScrollSingleTapBlock = ^void() {
        [weakSelf showOrHideControl];
    };

    self.viewPager = [[ViewPager alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [view addSubview:self.viewPager];
    self.viewPager.delegate = self;
    self.viewPager.backgroundColor = [UIColor whiteColor];
}

#pragma mark - ViewPager delegate

- (int)numberOfViewsInViewPager:(ViewPager *)viewPager {
    if (self.postList != nil) {
        return self.postList.count;
    } else {
        return 0;
    }
}

- (UIView *)viewPager:(ViewPager *)viewPager viewForIndex:(int)index size:(CGSize)size {
    Post *post = [self.postList getPostAt:index];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    BrowsePostCell *cell = [[BrowsePostCell alloc] initWithFrame:frame];
    cell.singleTapBlock = self.zoomScrollSingleTapBlock;
    cell.post = post;
    return cell;
}

- (void)viewPager:(ViewPager *)viewPager selectItem:(int)index currentView:(UIView *)view {
    Post *post = [self.postList getPostAt:index];
    self.title = [NSString stringWithFormat:@"%llu", post.postId];
    self.currentItemView = view;
    BrowsePostCell *cell = (BrowsePostCell *) view;
    [cell beginDownloadImage];

    FavouriteDB *favouriteDB = [FavouriteDB sharedInstance];
    if (![favouriteDB isFavourite:post.postId]) {
        [self.favButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_favoruite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [self.favButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_favoruite_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
}

- (void)viewPager:(ViewPager *)viewPager destroyItem:(UIView *)item {
    if ([item isKindOfClass:[BrowsePostCell class]]) {
        BrowsePostCell *imageView = (BrowsePostCell *) item;
        [imageView destroyFromViewPager];
    } else {

    }
}

#pragma mark - Control statusBar toolbar navigationBar

- (BOOL)prefersStatusBarHidden {
    return _statusBarShouldBeHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)showOrHideControl {
    _statusBarShouldBeHidden = !_statusBarShouldBeHidden;

    BOOL isVisible = ![UIApplication sharedApplication].statusBarHidden;
    if (isVisible) {
        [self hideControl];
    } else {
        [self showControl];
    }
}

- (void)showControl {
    _statusBarShouldBeHidden = NO;
    CGRect toolbarFrame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self setNeedsStatusBarAppearanceUpdate];
        [self.navigationController.navigationBar setAlpha:1.0];
        self.toolbar.frame = toolbarFrame;
        self.toolbar.alpha = 1.0;
        self.viewPager.backgroundColor = [UIColor whiteColor];
    }                completion:^(BOOL finished) {
    }];
}

- (void)hideControl {
    _statusBarShouldBeHidden = YES;
    CGRect toolbarFrame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
    toolbarFrame = CGRectOffset(toolbarFrame, 0, CGRectGetHeight(toolbarFrame));
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self setNeedsStatusBarAppearanceUpdate];
        [self.navigationController.navigationBar setAlpha:0.0];
        CGRect newNavigationBarFrame = self.navigationController.navigationBar.frame;
        newNavigationBarFrame.origin.y = 0;
        self.navigationController.navigationBar.frame = newNavigationBarFrame;
        self.toolbar.frame = toolbarFrame;
        self.toolbar.alpha = 0.0;
        self.viewPager.backgroundColor = [UIColor blackColor];
    }                completion:^(BOOL finished) {
    }];
}

#pragma mark - Toolbar Action

- (IBAction)slideShow:(id)sender {
    SlideShowViewController *controller = [[SlideShowViewController alloc] init];
    controller.sources = self.postList;
    controller.startIndex = self.viewPager.currentItem;
    __weak typeof(self) weakSelf = self;
    controller.dismissBlock = ^void() {
        [weakSelf showControl];
    };
    controller.switchBlock = ^void(int index) {
        [weakSelf.viewPager jumpToPageAtIndex:index animated:NO];
    };
    self.definesPresentationContext = YES;
    controller.view.backgroundColor = [UIColor clearColor];
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:controller animated:NO completion:^{

    }];
    [self hideControl];
}

- (void)action {
    Post *post = [self.postList getPostAt:self.viewPager.currentItem];
    NSString *url = post.sample_url;
    LocalCacheDB *db = [[LocalCacheManager sharedInstance] getCacheDB:@"yande"];
    NSString *cacheFile = [db queryCacheFile:url];
    if (cacheFile != nil && [[NSFileManager defaultManager] fileExistsAtPath:cacheFile isDirectory:NO]) {
        NSArray *items = @[[NSURL fileURLWithPath:cacheFile]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if ([UIActivityTypeSaveToCameraRoll isEqualToString:activityType] && completed) {
                [ToastView toastWithTitle:@"Saved successfully"];
            }
        }];
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        [ToastView toastWithTitle:@"High resolution picture is waiting for download"];
    }
}

- (void)fav {
    Post *post = [self.postList getPostAt:self.viewPager.currentItem];
    FavouriteDB *favouriteDB = [FavouriteDB sharedInstance];
    if (![favouriteDB isFavourite:post.postId]) {
        [favouriteDB addPost:post];
        [self.favButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_favoruite_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [favouriteDB deletePost:post.postId];
        [self.favButton setBackgroundImage:[[UIImage imageNamed:@"toolbar_favoruite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
}

- (void)fakeReport {
    UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:NSLocalizedString(@"Report",nil)
                             message:NSLocalizedString(@"Are you sure you want to report this post?",nil)
                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"Report",nil)
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) {
                        [self performSelector:@selector(fakeReportImp) withObject:[UIColor blueColor] afterDelay:1];
                    }];
    UIAlertAction *cancelAction = [UIAlertAction
            actionWithTitle:NSLocalizedString(@"Cancel",nil)
                      style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction *action) {

                    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)fakeReportImp {
    [ToastView toastWithTitle:NSLocalizedString(@"Report successfully",nil)];
}

- (void)moreAction {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *slideShow = [UIAlertAction actionWithTitle:NSLocalizedString(@"SlideShow",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self slideShow:nil];
    }];

    UIAlertAction *report = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self fakeReport];
    }];

//    UIAlertAction *detail = [UIAlertAction actionWithTitle:@"Picture detail" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//
//    }];
//
//    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save original picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//
//    }];


    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheetController dismissViewControllerAnimated:YES completion:nil];
    }];

    [actionSheetController addAction:slideShow];
    [actionSheetController addAction:report];
//    [actionSheetController addAction:detail];
//    [actionSheetController addAction:save];
    [actionSheetController addAction:cancel];

    actionSheetController.view.tintColor = [ThemeHelper tintColor];
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (PHAssetCollection *)createAlbumIfNotExistiOS8:(NSString *)name {
    NSString *albumName = name;
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    BOOL alreadyHaveAlbum = NO;
    __block PHAssetCollection *quickAlbum = nil;
    for (PHCollection *collection in topLevelUserCollections) {
        NSString *localizedTitle = collection.localizedTitle;
        if ([localizedTitle isEqualToString:albumName]) {
            alreadyHaveAlbum = YES;
            quickAlbum = (PHAssetCollection *) collection;
            break;
        }
    }

    if (!alreadyHaveAlbum) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block PHObjectPlaceholder *placeholder;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
            placeholder = [request placeholderForCreatedAssetCollection];

        }                                 completionHandler:^(BOOL success, NSError *error) {
            NSLog(@"AppDownloadDelegate create QuickPic album : %d", success);
            NSString *localIdentifier = placeholder.localIdentifier;
            NSArray *localIdentifiers = @[localIdentifier];
            PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:localIdentifiers options:nil];
            quickAlbum = result.firstObject;

            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return quickAlbum;
}

- (void)saveOriginalPicture {
    Post *post = [self.postList getPostAt:self.viewPager.currentItem];
    NSString *url = post.jpeg_url;
    [[ImageLoader sharedInstance] queryCacheFile:url block:^(NSString *url, NSString *cacheFile, NSError *error) {
        if (url == nil) {
            //fail
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                    (unsigned long) NULL), ^(void) {
                NSLog(@"ResourceManager begin insert album");
                PHAssetCollection *quickAlbum = [self createAlbumIfNotExistiOS8:@"AirBooru"];
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:cacheFile]];
                    PHObjectPlaceholder *placeholder = [request placeholderForCreatedAsset];
                    if (placeholder) {
                        PHAssetCollectionChangeRequest *addAssetRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:quickAlbum];
                        [addAssetRequest addAssets:@[placeholder]];
                    }
                }                                 completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        NSLog(@"ResourceManager insert to album successfully");
                    } else {
                        NSLog(@"ResourceManager insert to album failed %@", error);
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{

                });
            });
        }
    }];
}
@end
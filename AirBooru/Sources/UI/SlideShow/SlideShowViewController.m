//
// Created by qii on 6/3/15.
// Copyright (c) 2015 AirBooru. All rights reserved.
//

#import "SlideShowViewController.h"
#import "SlideShowView.h"
#import "ImageLoader.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "PostList.h"
#import "ImageLoaderOption.h"
#import "Post.h"

@interface SlideShowViewController ()
@property(assign, nonatomic) BOOL isCanceled;
@property(assign, nonatomic) BOOL isSlideShowAnimationBegan;

@property(strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property(strong, nonatomic) SlideShowView *slideShowView;
@property(copy, nonatomic) SlideShowAnimationCompletionBlock completionBlock;
@end

@implementation SlideShowViewController

- (void)loadView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.slideShowView.backgroundColor = [UIColor clearColor];
    self.view = self.slideShowView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];

    __weak typeof(self) weakSelf = self;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [weakSelf userDidTap:weakSelf.tapGestureRecognizer];
    }];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];

    self.completionBlock = ^void(int exitIndex) {
        if (weakSelf.isCanceled) {
            [weakSelf dismissSelf];
            return;
        }
        int count = weakSelf.sources.count;
        if (count == 1) {
            [weakSelf loadNext:0 nextEnterIndex:0];
        } else {
            if (exitIndex + 2 <= count - 1) {
                [weakSelf loadNext:exitIndex + 1 nextEnterIndex:exitIndex + 2];
            } else if (exitIndex + 1 <= count - 1) {
                [weakSelf loadNext:exitIndex + 1 nextEnterIndex:0];
            } else {
                [weakSelf loadNext:0 nextEnterIndex:1];
            }
        }
    };

    self.slideShowView.completionBlock = self.completionBlock;
    self.completionBlock(self.startIndex - 1);
}

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    self.isCanceled = YES;
    if (!self.isSlideShowAnimationBegan) {
        [self dismissSelf];
    }
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.slideShowView removeFromSuperview];
        self.view.backgroundColor = [UIColor clearColor];

        if (self.dismissBlock != nil) {
            self.dismissBlock();
        }
    }];
}

- (void)loadNext:(int)exitIndex nextEnterIndex:(int)enterIndex {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (self.isCanceled) {
            [self dismissSelf];
        }
        self.isSlideShowAnimationBegan = NO;
        NSArray *array = @[@(exitIndex), @(enterIndex)];
        [self performSelector:@selector(loadNextImp:) withObject:array afterDelay:3];
    }];
}

- (IBAction)loadNextImp:(id)arguments {
    if (self.isCanceled) {
        return;
    }
    NSArray *indexArray = (NSArray *) arguments;
    int exitIndex = ((NSNumber *) indexArray[0]).intValue;
    int enterIndex = ((NSNumber *) indexArray[1]).intValue;

    CGSize thumbnailSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    Post *exitPost = [self.sources getPostAt:exitIndex];
    Post *enterPost = [self.sources getPostAt:enterIndex];

    ABUImageLoaderSuccessBlock successBlock = ^void(NSString *url, UIImage *exitImage) {
        ImageLoaderOption *option = [[ImageLoaderOption alloc] initWithSize:thumbnailSize successBlock:^(NSString *url, UIImage *enterImage) {
            self.slideShowView.exitImage = exitImage;
            self.slideShowView.exitIndex = exitIndex;
            self.slideShowView.enterImage = enterImage;
            self.isSlideShowAnimationBegan = YES;
            [self.slideShowView start];

            if (self.switchBlock != nil) {
                self.switchBlock(enterIndex);
            }
            self.view.backgroundColor = [UIColor blackColor];
        }                                                      percentBlock:^(NSString *url, float percent) {

        }                                                      failureBlock:^(NSString *url, NSError *error) {

        }];
        [[ImageLoader sharedInstance] loadImage:enterPost.sample_url option:option];
    };

    ABUImageLoaderPercentBlock percentBlock = ^void(NSString *url, float percent) {

    };

    ABUImageLoaderFailureBlock failureBlock = ^void(NSString *url, NSError *error) {

    };
    ImageLoaderOption *option = [[ImageLoaderOption alloc] initWithSize:CGSizeMake(300, 300)
                                                           successBlock:successBlock
                                                           percentBlock:percentBlock
                                                           failureBlock:failureBlock];
    [[ImageLoader sharedInstance] loadImage:exitPost.sample_url option:option];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)dealloc {
    NSLog(@"SlideShowViewController dealloc");
}

@end
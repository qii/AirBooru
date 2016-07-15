//
// Created by qii on 5/2/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "BrowsePostCell.h"
#import "Post.h"
#import "ImageLoader.h"
#import "ImageLoaderOption.h"
#import "CircleProgressView.h"
#import "UIView+StringTagAdditions.h"

@interface BrowsePostCell ()
@property(strong, nonatomic) GesturePictureView *imageView;
@property(strong, nonatomic) CircleProgressView *indicatorView;
@property(copy, nonatomic) SingleTapBlock innerZoomScrollSingleTapBlock;
@property(assign, nonatomic) BOOL isHighResolutionPictureLoaded;
@property(strong, nonatomic) UILabel *tipLabel;
@end

@implementation BrowsePostCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isHighResolutionPictureLoaded = NO;
        self.imageView = [[GesturePictureView alloc] initWithFrame:self.bounds];
        __weak BrowsePostCell *weakSelf = self;
        self.innerZoomScrollSingleTapBlock = ^void() {
            weakSelf.singleTapBlock();
        };
        self.imageView.singleTapBlock = self.innerZoomScrollSingleTapBlock;

        self.indicatorView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//        self.indicatorView.backgroundColor=[UIColor redColor];

        [self addSubview:self.imageView];
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)setPost:(Post *)post {
    _post = post;
    [self loadPreviewImage];
}

- (void)beginDownloadImage {
    [self loadHighResImage];
}

- (void)destroyFromViewPager {
    [[ImageLoader sharedInstance] cancelLoadImage:self.post.sample_url];
}

- (BOOL)isViewTagSame {
    NSString *tag = self.imageView.abu_stringTag;
    return [@(self.post.postId).stringValue isEqualToString:tag];
}

- (void)loadPreviewImage {
    self.imageView.image = nil;
    self.imageView.abu_stringTag = @(self.post.postId).stringValue;

    ABUImageLoaderSuccessBlock successBlock = ^void(NSString *url, UIImage *image) {
        if ([self isViewTagSame] && !self.isHighResolutionPictureLoaded) {
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.indicatorView.hidden = NO;
        }
    };

    ABUImageLoaderPercentBlock percentBlock = ^void(NSString *url, float percent) {
        if ([self isViewTagSame]) {
            self.indicatorView.progress = percent;
        }
    };

    ABUImageLoaderFailureBlock failureBlock = ^void(NSString *url, NSError *error) {
        if ([self isViewTagSame]) {
            self.indicatorView.hidden = YES;
        }
    };

    ImageLoaderOption *option = [[ImageLoaderOption alloc] initWithSize:CGSizeMake(300, 300)
                                                           successBlock:successBlock
                                                           percentBlock:percentBlock
                                                           failureBlock:failureBlock];
    [[ImageLoader sharedInstance] loadImage:self.post.preview_url option:option];
}

- (void)loadHighResImage {
    if (self.isHighResolutionPictureLoaded) {
        return;
    }
    self.indicatorView.progress = 0.0f;
    ABUImageLoaderSuccessBlock successBlock = ^void(NSString *url, UIImage *image) {
        if ([self isViewTagSame]) {
            self.indicatorView.hidden = YES;
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.isHighResolutionPictureLoaded = YES;
            if (self.tipLabel != nil) {
                [self.tipLabel removeFromSuperview];
            }
        }
    };

    ABUImageLoaderPercentBlock percentBlock = ^void(NSString *url, float percent) {
        if ([self isViewTagSame]) {
            self.indicatorView.progress = percent;
            self.indicatorView.hidden = NO;
            if (self.tipLabel != nil) {
                [self.tipLabel removeFromSuperview];
            }
        }
    };

    ABUImageLoaderFailureBlock failureBlock = ^void(NSString *url, NSError *error) {
        if ([self isViewTagSame]) {
            self.indicatorView.hidden = YES;
            [self addTipLabel:@"Can't load picture"];
        }
    };
    ImageLoaderOption *option = [[ImageLoaderOption alloc] initWithSize:CGSizeMake(300, 300)
                                                           successBlock:successBlock
                                                           percentBlock:percentBlock
                                                           failureBlock:failureBlock];
    [[ImageLoader sharedInstance] loadImage:self.post.sample_url option:option];
}

- (void)addTipLabel:(NSString *)tip {
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.tipLabel.text = tip;
    [self.tipLabel sizeToFit];
    self.tipLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:self.tipLabel];
}
@end
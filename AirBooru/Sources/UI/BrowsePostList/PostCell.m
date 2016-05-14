//
// Created by qii on 4/27/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "PostCell.h"
#import "Post.h"
#import "ImageLoader.h"
#import "ImageLoaderOption.h"
#import "CircleProgressView.h"
#import "UIView+StringTagAdditions.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "ThemeHelper.h"

@interface PostCell ()
@property(strong, nonatomic) IBOutlet UIImageView *imageView;
@property(strong, nonatomic) CircleProgressView *indicatorView;
@property(nonatomic, strong) UIImageView *selectedImageView;
@end

@implementation PostCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.editing = NO;
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
        }];

        self.indicatorView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//        self.indicatorView.backgroundColor = [UIColor redColor];
        self.indicatorView.hidden = YES;
        [self.contentView addSubview:self.indicatorView];

        self.selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.selectedImageView.image = [[UIImage imageNamed:@"cell_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.selectedImageView.tintColor = [ThemeHelper tintColor];
        self.selectedImageView.hidden = YES;
        [self.contentView addSubview:self.selectedImageView];
        [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-5);
            make.bottom.equalTo(self.mas_bottom).offset(-5);
            make.width.equalTo(@30);
            make.height.equalTo(@30);
        }];

        self.contentView.clipsToBounds = YES;
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)coder {
//    self = [super initWithCoder:coder];
//    if (self) {
//        self.indicatorView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
//        self.indicatorView.backgroundColor = [UIColor redColor];
//        self.indicatorView.hidden = YES;
//        [self.contentView addSubview:self.indicatorView];
//    }
//    return self;
//}

- (BOOL)isViewTagSame:(NSString *)url {
    NSString *tag = self.imageView.abu_stringTag;
    return [url isEqualToString:tag];
}

- (void)setPost:(Post *)post {
    _post = post;

    NSString *url = post.preview_url;
    self.imageView.abu_stringTag = url;
    self.imageView.image = nil;
    self.indicatorView.hidden = NO;
    ImageLoaderOption *option = [[ImageLoaderOption alloc] initWithSize:CGSizeMake(300, 300)
                                                           successBlock:^(NSString *url, UIImage *image) {
                                                               if ([self isViewTagSame:url]) {
                                                                   self.imageView.image = image;
                                                                   self.imageView.contentMode = UIViewContentModeScaleAspectFill;
                                                                   self.indicatorView.hidden = YES;
                                                               }
                                                           } percentBlock:^(NSString *url, float percent) {
                if ([self isViewTagSame:url]) {
                    self.indicatorView.progress = percent;
                }
            }                                              failureBlock:^(NSString *url, NSError *error) {
                if ([self isViewTagSame:url]) {
                    self.imageView.image = [UIImage imageNamed:@"icon_error"];
                    self.imageView.contentMode = UIViewContentModeCenter;
                    self.indicatorView.hidden = YES;
                }
                NSLog(@"PostCell loadImage fail%@", error);

            }];
    [[ImageLoader sharedInstance] loadImage:url option:option];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedImageView.hidden = !selected || !self.editing;
}

@end
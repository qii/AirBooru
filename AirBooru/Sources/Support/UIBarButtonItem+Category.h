//
//  UIBarButtonItem+Category.h
//  SinaWeibo
//
//  Created by android_ls on 15/5/19.
//  Copyright (c) 2015年 android_ls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Category)

#pragma mark 设置左侧文字和图片组成的按钮的外观样式
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage title:(NSString *)title;

#pragma mark 设置左侧按钮的外观样式（只有图片）
+ (UIBarButtonItem *)leftBarButtonItemWithTarget:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage;

#pragma mark 设置右侧按钮的外观样式（只有图片）
+ (UIBarButtonItem *)rightBarButtonItemWithTarget:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage;

@end

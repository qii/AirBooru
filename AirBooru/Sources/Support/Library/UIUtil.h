#import <UIKit/UIKit.h>

//
@interface UIDevice (uniqueIdentifier)
- (NSString *)uniqueIdentifier;
@end

//
#pragma mark - Device methods

//
NS_INLINE NSString *UIDeviceID() {
    if ([UIDevice.currentDevice respondsToSelector:@selector(identifierForVendor)]) {
        return UIDevice.currentDevice.identifierForVendor.UUIDString;
    }
    return [UIDevice.currentDevice uniqueIdentifier];
}

//
NS_INLINE float UISystemVersion() {
    return UIDevice.currentDevice.systemVersion.floatValue;
}

//
NS_INLINE BOOL UIIsPad() {
    return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

//
NS_INLINE BOOL UIIsOS7() {
    return UISystemVersion() >= 7.0;
}

//
NS_INLINE BOOL UIIsOS8() {
    return UISystemVersion() >= 8.0;
}

//
NS_INLINE CGFloat UIScreenScale() {
    return UIScreen.mainScreen.scale;
}

//
NS_INLINE CGFloat UIThinLineHeight() {
    return (UIScreenScale() > 1) ? 0.5 : 1;
}

//
NS_INLINE CGRect UIScreenBounds() {
    return UIScreen.mainScreen.bounds;
}

//
NS_INLINE CGSize UIScreenSize() {
    return UIScreenBounds().size;
}

//
NS_INLINE CGFloat UIScreenWidth() {
    return UIScreenSize().width;
}

//
NS_INLINE CGFloat UIScreenHeight() {
    return UIScreenSize().height;
}

//
NS_INLINE CGRect UIAppFrame() {
    return UIScreen.mainScreen.applicationFrame;
}

//
NS_INLINE BOOL UIIsRetina() {
    return UIScreenScale() > 1;
}

//
NS_INLINE BOOL UIIsPhone5() {
    return UIScreenHeight() > 480;
}

//
NS_INLINE BOOL UIIsPhone6() {
    return UIScreenWidth() > 320;
}


#pragma mark - Application methods

//
NS_INLINE UIViewController *UIRootViewController() {
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

//
NS_INLINE UIViewController *UIFrontViewController() {
    UIViewController *controller = UIRootViewController();
    UIViewController *presented = controller.presentedViewController;
    return presented ? presented : controller;
}

//
NS_INLINE UIViewController *UIVisibleViewController() {
    UIViewController *controller = UIFrontViewController();
    while (YES) {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            controller = ((UINavigationController *) controller).visibleViewController;
        }
        else if ([controller isKindOfClass:[UITabBarController class]]) {
            controller = ((UITabBarController *) controller).selectedViewController;
        }
        else {
            return controller;
        }
    }
}

//
NS_INLINE BOOL UICanOpenUrl(NSString *url) {
    return [UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:url]];
}

//
#ifndef _AlertView
#define _AlertView UIAlertView
#endif

NS_INLINE BOOL UIOpenUrl(NSString *url) {
    if (url.length == 0) return NO;
    BOOL ret = [UIApplication.sharedApplication openURL:[NSURL URLWithString:url]];
    if (ret == NO) {
        _AlertView *alertView = [[_AlertView alloc] initWithTitle:[url hasPrefix:@"tel"] ? NSLocalizedString(@"Could not make call", @"无法拨打电话") : NSLocalizedString(@"Could not open", @"无法打开")
                                                          message:url
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                                otherButtonTitles:nil];
        [alertView show];
    }
    return ret;
}

//
NS_INLINE BOOL UIOpenUrlWithTelPrompt(NSString *url) {
    if ([url hasPrefix:@"tel:"]) {
        url = [url stringByReplacingOccurrencesOfString:@"tel:" withString:@"telprompt:"];
    }
    return UIOpenUrl(url);
}

//
NS_INLINE BOOL UIOpenUrlWithEscape(NSString *url) {
    return UIOpenUrl([url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
}

//
NS_INLINE BOOL UIMakeCall(NSString *number, BOOL direct) {
    NSString *url = [NSString stringWithFormat:(direct ? @"tel://%@" : @"telprompt://%@"), [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *URL = [NSURL URLWithString:url];

    BOOL ret = [UIApplication.sharedApplication openURL:URL];
    if (ret == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not make call", @"无法拨打电话")
                                                            message:number
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    return ret;
}

//
NS_INLINE UIWindow *UIKeyWindow() {
    return UIApplication.sharedApplication.keyWindow;
}

//
NS_INLINE BOOL UIIsWindowLandscape() {
    CGSize size = UIKeyWindow().frame.size;
    return size.width > size.height;
}

//
NS_INLINE void UIShowStatusBar(BOOL show, UIStatusBarAnimation animated) {
    [UIApplication.sharedApplication setStatusBarHidden:!show withAnimation:animated];
}


#pragma mark - Color methods

// UIColor from HTML color
NS_INLINE UIColor *UIColorWithString(NSString *code) {
    NSUInteger length = code.length;
    if ((length == 6) || (length == 8)) {
        unsigned char color[8];
        sscanf(code.UTF8String, "%02X%02X%02X%02X", (unsigned int *) &color[0], (unsigned int *) &color[1], (unsigned int *) &color[2], (unsigned int *) &color[3]);
        if (length == 6) {
            color[3] = 0xFF;
        }
        return [UIColor colorWithRed:color[0] / 255.0 green:color[1] / 255.0 blue:color[2] / 255.0 alpha:color[3] / 255.0];
    }
    return [UIColor blackColor];
}

// UIColor from RGB
NS_INLINE UIColor *UIColorWithRGB(NSUInteger rgb) {
    //NSUInteger transparent = (rgb & 0xFF000000) >> 24;
    //CGFloat alpha = (0xFF - transparent) / 255.0;
    return [UIColor colorWithRed:((rgb & 0x00FF0000) >> 16) / 255.0
                           green:((rgb & 0x0000FF00) >> 8) / 255.0
                            blue:((rgb & 0x000000FF)) / 255.0
                           alpha:1];
}

#pragma mark - Image methods

//
NS_INLINE UIImage *UICacheImageBundled(NSString *name) {
#ifdef kAssetBundle
	name = [kAssetBundle stringByAppendingPathComponent:name];
#endif
    return [UIImage imageNamed:name];
}

//
NS_INLINE UIImage *UIUnCacheImageBundled(NSString *name) {
    // 支持无 @1x 时使用
    if (![name hasSuffix:@".png"]) name = [name stringByAppendingString:@"@2x.png"];
    return [UIImage imageWithContentsOfFile:(name)];
}

//
NS_INLINE UIImage *UIImageBundled(NSString *name) {
#ifdef _UIUnCacheImageBundled
	return UIUnCacheImageBundled(file);
#else
    return UICacheImageBundled(name);
#endif
}

// Param name must NOT have suffix @".png"
NS_INLINE UIImage *UIImageBundled2X(NSString *name) {
    return UIImageBundled([name stringByAppendingString:UIIsPad() ? @"@2x.png" : @".png"]);
}

//
NS_INLINE UIImage *UIImageStretchable(UIImage *image) {
    return [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
}

//
NS_INLINE UIImage *UIImageWithColorAndSize(UIColor *color, CGSize size) {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

//
NS_INLINE UIImage *UIImageWithColor(UIColor *color) {
    return UIImageWithColorAndSize(color, CGSizeMake(1, 1));
}

//
NS_INLINE UIImage *UIImageWithGradientColors(const CGFloat components[], size_t count, CGSize size) {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, count);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0, size.height), kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

NS_INLINE UIImage *UIImageMaskWithColor(UIImage *image, UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//
NS_INLINE UIImage *UIImageWithView(UIView *view) {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

//
NS_INLINE BOOL UINormalizePngFile(NSString *dst, NSString *src) {
    NSString *dir = dst.stringByDeletingLastPathComponent;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }

    UIImage *image = [UIImage imageWithContentsOfFile:src];
    if (image == nil) return NO;

    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) return NO;

    return [data writeToFile:dst atomically:NO];
}

//
NS_INLINE void UINormalizePngFolder(NSString *dst, NSString *src) {
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:src];
    for (NSString *file in files) {
        if ([file.lowercaseString hasSuffix:@".png"]) {
            UINormalizePngFile([dst stringByAppendingPathComponent:file], [src stringByAppendingPathComponent:file]);
        }
    }
}

#pragma mark - UIView methods

//
NS_INLINE UIView *UIViewWithColor(CGRect frame, UIColor *color) {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = color;
    return view;
}

//
#ifndef kSeparatorColor
#define kSeparatorColor [UIColor colorWithRed:200/255.0 green:199/255.0 blue:194/255.0 alpha:1]
#endif

NS_INLINE UIView *UILineWithFrame(CGRect frame) {
    frame.size.height = UIThinLineHeight();
    UIView *line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = kSeparatorColor;
    return line;
}

//
NS_INLINE UIView *UILineWithWidth(CGFloat width) {
    return UILineWithFrame(CGRectMake(0, 0, width, 0));
}

//
NS_INLINE void UIRemoveSubviews(UIView *view) {
    while (view.subviews.count) {
        UIView *child = view.subviews.lastObject;
        [child removeFromSuperview];
    }
}

//
NS_INLINE UIView *UIFindFirstResponder(UIView *view) {
    if ([view isFirstResponder]) {
        return view;
    }

    for (UIView *subview in view.subviews) {
        UIView *ret = UIFindFirstResponder(subview);
        if (ret) {
            return ret;
        }
    }
    return nil;
}

//
NS_INLINE UIView *UIFindSubview(UIView *view, Class viewClass) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:viewClass]) {
            return subview;
        }
        else {
            UIView *ret = UIFindSubview(subview, viewClass);
            if (ret) {
                return ret;
            }
        }
    }

    return nil;
}

//
NS_INLINE UIView *UIFindSuperview(UIView *view, Class viewClass) {
    while ((view = view.superview)) {
        if ([view isKindOfClass:viewClass]) {
            return view;
        }
    }
    return nil;
}

//
NS_INLINE UIActivityIndicatorView *UIShowActivityIndicator(UIView *view, BOOL show) {
    const static NSInteger kActivityViewTag = 53214;
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *) [view viewWithTag:kActivityViewTag];
    if (show == NO) {
        [activityView removeFromSuperview];
        return nil;
    }
    else if (activityView == nil) {
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
        activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [view addSubview:activityView];
        [activityView startAnimating];
        activityView.tag = kActivityViewTag;
    }
    return activityView;
}

//
NS_INLINE UIImageView *UIShowSplash(UIView *view, CGFloat duration) {
    //
    CGRect frame = UIScreenBounds();
    UIImageView *splashView = [[UIImageView alloc] initWithFrame:frame];
    splashView.image = [UIImage imageNamed:UIIsPad() ? @"Default@iPad.png" : (UIIsPhone5() ? @"Default-568h.png" : @"Default.png")];
    splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [UIKeyWindow() addSubview:splashView];

    //
    view.alpha = 0;

    [UIView animateWithDuration:duration animations:^() {
        view.alpha = 1;
        splashView.alpha = 0;
    }                completion:^(BOOL finished) {
        [splashView removeFromSuperview];
    }];

    return splashView;
}

//
NS_INLINE void UIShakeAnimating(UIView *view, void (^completion)(BOOL finished)) {
    [UIView animateWithDuration:0.1 animations:^() {
        view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -20, 0);
    }                completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^() {
            view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 20, 0);
        }                completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^() {
                view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -20, 0);

            }                completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^() {
                    view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
                }                completion:completion];
            }];

        }];
    }];
}

#pragma mark - Label methods

//
NS_INLINE UILabel *UILabelWithFrame(CGRect frame, NSString *text, UIFont *font, UIColor *color) {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.text = text;

    return label;
}

//
NS_INLINE UILabel *UILabelAtPoint(CGPoint point, CGFloat width, NSString *text, UIFont *font, UIColor *color) {
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:CGSizeMake(width, 1000)];

    CGRect frame = CGRectMake(point.x, point.y, width, ceil(size.height));

    UILabel *label = UILabelWithFrame(frame, text, font, color);
    label.numberOfLines = 0;
    return label;
}

#pragma mark - Alert View methods

//
NS_INLINE UIAlertView *UIAlertViewWithTitleAndMessage(NSString *title, NSString *message) {
    UIAlertView *alertView = [[_AlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
    [alertView show];
    return alertView;
}

//
NS_INLINE UIAlertView *UIAlertViewWithTitle(NSString *title) {
    return UIAlertViewWithTitleAndMessage(title, nil);
}

//
NS_INLINE UIAlertView *UIAlertViewWithMessage(NSString *message) {
    return UIAlertViewWithTitleAndMessage(@"", message);
}

#pragma mark - Misc methods

//
NS_INLINE UITableViewCellAccessoryType UITableViewCellAccessoryButton() {
    return UIIsOS7() ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryDetailDisclosureButton;
}

#pragma mark - Log Extension methods

//
NS_INLINE void UILogIndentString(NSUInteger indent, NSString *str) {
    NSString *log = @"";
    for (NSUInteger i = 0; i < indent; i++) {
        log = [log stringByAppendingString:@"\t"];
    }
    log = [log stringByAppendingString:str];
    NSLog(@"%@", log);
}

// Log controller and sub-controllers
NS_INLINE void UILogController(UIViewController *controller, NSUInteger indent) {
    UILogIndentString(indent, [NSString stringWithFormat:@"<Controller Description=\"%@\">", [controller description]]);

    if (controller.presentedViewController) {
        UILogController(controller, indent + 1);
    }

    if ([controller isKindOfClass:[UINavigationController class]]) {
        for (UIViewController *child in ((UINavigationController *) controller).viewControllers) {
            UILogController(child, indent + 1);
        }
    }
    else if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *) controller;
        for (UIViewController *child in tabBarController.viewControllers) {
            UILogController(child, indent + 1);
        }

        if (tabBarController.moreNavigationController) {
            UILogController(tabBarController.moreNavigationController, indent + 1);
        }
    }

    UILogIndentString(indent, @"</Controller>");
}

// Log view and subviews
NS_INLINE void UILogView(UIView *view, NSUInteger indent) {
    CGRect frame = [view.superview convertRect:view.frame toView:nil];
    NSString *rect = NSStringFromCGRect(frame);

    UILogIndentString(indent, [NSString stringWithFormat:@"<View%@ Description=\"%@\">", rect, [view description]]);

    for (UIView *child in view.subviews) {
        UILogView(child, indent + 1);
    }

    UILogIndentString(indent, @"</View>");
}


#if defined(DEBUG) || defined(TEST)
#define _LogView(v)            UIULogView(v)
#define _LogController(c)    UIULogController(c)
#define _LogConstraints(v)    UIULogConstraints(v)
#else
#define _LogView(v)			((void) 0)
#define _LogConstraints(v)	((void) 0)
#define _LogController(c)	((void) 0)
#endif

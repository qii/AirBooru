//
// Created by qii on 5/10/15.
// Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//

#import "ImageHelper.h"
#import <ImageIO/ImageIO.h>


@implementation ImageHelper

+ (UIImage *)scaleImageToSize:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (BOOL)canReadImageAt:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO]) {
        return NO;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageRef myImage = NULL;
    CGImageSourceRef myImageSource;
    CFDictionaryRef myOptions = NULL;
    CFStringRef myKeys[4];
    CFTypeRef myValues[4];

    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef) kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef) kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (__bridge void *) @1024;
    myKeys[3] = kCGImageSourceCreateThumbnailFromImageAlways;
    myValues[3] = (CFTypeRef) kCFBooleanTrue;

    // Create the dictionary
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
            (const void **) myValues, 4,
            &kCFTypeDictionaryKeyCallBacks,
            &kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef) url, myOptions);

//    CFRelease(myOptions);
    // Make sure the image source exists before continuing
    if (myImageSource == NULL) {
        fprintf(stderr, "Image source is NULL.");
        return NO;
    }

    CFDictionaryRef r = CGImageSourceCopyPropertiesAtIndex(myImageSource, 0, NULL);
    NSLog(@"haha");
    // Create an image from the first item in the image source.
//    myImage = CGImageSourceCreateImageAtIndex(myImageSource,
//            0,
//            NULL);

    CFDictionaryRef g = CGImageSourceCopyProperties(myImageSource, nil);

    myImage = CGImageSourceCreateThumbnailAtIndex(myImageSource, 0, myOptions);


    CFRelease(myImageSource);
    // Make sure the image exists before continuing
    if (myImage == NULL) {
        fprintf(stderr, "Image not created from image source.");
        return NULL;
    }

    return myImage;
}

+ (BOOL)hasAlpha:(UIImage *)image {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

+ (NSUInteger)calcImageMemCacheCost:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
    NSUInteger cost = CGImageGetWidth(imageRef) * CGImageGetHeight(imageRef) * bytesPerPixel;
    return cost;
}
@end
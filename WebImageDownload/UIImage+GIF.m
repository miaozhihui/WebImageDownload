//
//  UIImage+GIF.m
//  Download
//
//  Created by miaozhihui on 2017/6/13.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "UIImage+GIF.h"
#import <ImageIO/ImageIO.h>
#import "Compat.h"

@implementation UIImage (GIF)

+ (nullable UIImage *)animatedGIFWithData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *staticImage;
    if (count <= 1) {
        staticImage = [[UIImage alloc] initWithData:data];
    } else {
#if SD_WATCH
        CGFloat scale = 1;
        scale = [WKInterfaceDevice currentDevice].screenScale;
#elif SD_UIKIT
        CGFloat scale = 1;
        scale = [UIScreen mainScreen].scale;
#endif
        CGImageRef CGImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
#if SD_UIKIT || SD_WATCH
        UIImage *frameImage = [UIImage imageWithCGImage:CGImage scale:scale orientation:UIImageOrientationUp];
        staticImage = [UIImage animatedImageWithImages:@[frameImage] duration:0.0f];
#elif SD_MAC
        staticImage = [[UIImage alloc] initWithCGImage:CGImage size:NSZeroSize];
#endif
        CGImageRelease(CGImage);
    }
    CFRelease(source);
    return staticImage;
}

- (BOOL)isGIF {
    return (self.images != nil);
}

@end

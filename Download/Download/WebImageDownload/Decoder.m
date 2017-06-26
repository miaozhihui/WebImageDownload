//
//  UIImage+Decoder.m
//  Download
//
//  Created by miaozhihui on 2017/5/24.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Decoder.h"

@implementation UIImage (Decoder)

#if SD_UIKIT
static const size_t KBytesPerPixel = 4;
static const size_t KBitsPerComponent = 8;

+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image {
    if (![UIImage shouldDecodeImage:image]) {
        return image;
    }
    @autoreleasepool {
        CGImageRef imageRef = image.CGImage;
        CGColorSpaceRef colorSpaceRef = [UIImage colorSpaceForImageRef:imageRef];
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        size_t bytesPerRow = KBytesPerPixel * width;
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, KBitsPerComponent, bytesPerRow, colorSpaceRef, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        if (context == NULL) {
            return image;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha scale:image.scale orientation:image.imageOrientation];
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        return imageWithoutAlpha;
    }
}

static const CGFloat KDestImageSizeMB = 60.0f;
static const CGFloat KSourceImageTileSizeMB = 20.0f;
static const CGFloat KBytesPerMB = 1024.0f * 1024.0f;
static const CGFloat KPixelsPerMB = KBytesPerMB / KBytesPerPixel;
static const CGFloat KDestTotalPixels = KDestImageSizeMB * KPixelsPerMB;
static const CGFloat KTileTotalPixels = KSourceImageTileSizeMB * KPixelsPerMB;
static const CGFloat KDestSeemOverlap = 2.0f;

+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    if (![UIImage shouldDecodeImage:image]) {
        return image;
    }
    if (![UIImage shouldScaleDownImage:image]) {
        return image;
    }
    CGContextRef destContext;
    @autoreleasepool {
        CGImageRef sourceImageRef = image.CGImage;
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef);
        sourceResolution.height = CGImageGetHeight(sourceImageRef);
        float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        float imageScale = KDestTotalPixels / sourceTotalPixels;
        CGSize destResolution = CGSizeZero;
        destResolution.width = (int)(sourceResolution.width * imageScale);
        destResolution.height = (int)(sourceResolution.height * imageScale);
        CGColorSpaceRef colorSpaceRef = [UIImage colorSpaceForImageRef:sourceImageRef];
        size_t bytesPerRow = KBytesPerPixel * destResolution.width;
        void *destBitmapData = malloc(bytesPerRow * destResolution.height);
        if (destBitmapData == NULL) {
            return image;
        }
        destContext = CGBitmapContextCreate(destBitmapData, destResolution.width, destResolution.height, KBitsPerComponent, bytesPerRow, colorSpaceRef, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        if (destContext == NULL) {
            free(destBitmapData);
            return image;
        }
        CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        sourceTile.size.height = (int)(KTileTotalPixels / sourceTile.size.width);
        sourceTile.origin.x = 0.0f;
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        float sourceSeemOverlap = (int)((KDestSeemOverlap / destResolution.height) * sourceResolution.height);
        CGImageRef sourceTileImageRef;
        int iterations = (int)(sourceResolution.height / sourceTile.size.height);
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if (remainder) {
            iterations++;
        }
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += KDestSeemOverlap;
        for (int y = 0; y < iterations; ++y) {
            @autoreleasepool {
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = destResolution.height - ((y + 1) * sourceTileHeightMinusOverlap * imageScale + KDestSeemOverlap);
                sourceTileImageRef = CGImageCreateWithImageInRect(sourceImageRef, sourceTile);
                if (y == iterations - 1 && remainder) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight(sourceTileImageRef) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                CGContextDrawImage(destContext, destTile, sourceTileImageRef);
                CGImageRelease(sourceTileImageRef);
            }
        }
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }
        UIImage *destImage = [UIImage imageWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
}


+ (BOOL)shouldDecodeImage:(nullable UIImage *)image {
    if (image == nil) {
        return NO;
    }
    if (image.images != nil) {
        return NO;
    }
    CGImageRef imageRef = image.CGImage;
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast);
    if (anyAlpha) {
        return NO;
    }
    return YES;
}

+ (CGColorSpaceRef)colorSpaceForImageRef:(CGImageRef)imageRef {
    CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
    BOOL unsupportedColorSpace = (imageColorSpaceModel == kCGColorSpaceModelUnknown ||
                                  imageColorSpaceModel == kCGColorSpaceModelMonochrome ||
                                  imageColorSpaceModel == kCGColorSpaceModelCMYK ||
                                  imageColorSpaceModel == kCGColorSpaceModelIndexed);
    if (unsupportedColorSpace) {
        colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CFAutorelease(colorSpaceRef);
    }
    return colorSpaceRef;
}

+ (BOOL)shouldScaleDownImage:(nonnull UIImage *)image {
    BOOL shouldScaleDown = YES;
    CGImageRef sourceImageRef = image.CGImage;
    CGSize sourceResolution = CGSizeZero;
    sourceResolution.width = CGImageGetWidth(sourceImageRef);
    sourceResolution.height = CGImageGetHeight(sourceImageRef);
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    float imageScale = KDestTotalPixels / sourceTotalPixels;
    if (imageScale < 1) {
        shouldScaleDown = YES;
    } else {
        shouldScaleDown = NO;
    }
    return shouldScaleDown;
}

#elif SD_MAC
+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image {
    return image;
}

+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    return image;
}
#endif

@end

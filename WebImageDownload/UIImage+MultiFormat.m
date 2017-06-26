//
//  UIImage+MultiFormat.m
//  Download
//
//  Created by miaozhihui on 2017/6/13.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"
#import "Compat.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (MultiFormat)

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    UIImage *image;
    ImageFormat imageFormat = [NSData imageFormatForImageData:data];
    if (imageFormat == ImageFormatGIF) {
        image = [UIImage animatedGIFWithData:data];
    }
#ifdef SD_WEBP
    else if (imageFormat == ImageFormatWebP) {
        image = [UIImage imageWithWebPData:data];
    }
#endif
    else {
        image = [[UIImage alloc] initWithData:data];
#if SD_UIKIT || SD_WATCH
        UIImageOrientation orientation = [self imageOrientationFromImageData:data];
        if (orientation != UIImageOrientationUp) {
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:orientation];
        }
#endif
    }
    return image;
}

#if SD_UIKIT || SD_WATCH
+ (UIImageOrientation)imageOrientationFromImageData:(nonnull NSData *)imageData {
    UIImageOrientation result = UIImageOrientationUp;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (imageSource) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (properties) {
            CFTypeRef val;
            int exifOrientation;
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) {
                CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
                result = [self exifOrientationToiOSOrientation:exifOrientation];
            }
            CFRelease((CFTypeRef)properties);
        }
        CFRelease(imageSource);
    }
    return result;
}

+ (UIImageOrientation)exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
        case 3:
            orientation = UIImageOrientationDown;
            break;
        case 8:
            orientation = UIImageOrientationLeft;
            break;
        case 6:
            orientation = UIImageOrientationRight;
            break;
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return orientation;
}

#endif

- (nullable NSData *)imageData {
    return [self imageDataAsFormat:ImageFormatUndefined];
}

- (nullable NSData *)imageDataAsFormat:(ImageFormat)imageFormat {
    NSData *imageData = nil;
    if (self) {
#if SD_UIKIT || SD_WATCH
        int alphaInfo = CGImageGetAlphaInfo(self.CGImage);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                         alphaInfo == kCGImageAlphaNoneSkipFirst ||
                         alphaInfo == kCGImageAlphaNoneSkipLast);
        BOOL usePNG = hasAlpha;
        if (imageFormat != ImageFormatUndefined) {
            usePNG = (imageFormat == ImageFormatPNG);
        }
        if (usePNG) {
            imageData = UIImagePNGRepresentation(self);
        } else {
            imageData = UIImageJPEGRepresentation(self, (CGFloat)1.0);
        }
#else
        NSBitmapImageFileType imageFileType = NSJPEGFileType;
        if (imageFormat == ImageFormatGIF) {
            imageFileType = NSGIFFileType;
        } else if (imageFormat == ImageFormatPNG) {
            imageFileType = NSPNGFileType;
        }
        imageData = [NSBitmapImageRep representationOfImageRepsInArray:self.representations usingType:imageFileType properties:@{}];
#endif
    }
    return imageData;
}

@end

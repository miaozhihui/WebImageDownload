//
//  NSData+ImageContentType.m
//  Download
//
//  Created by miaozhihui on 2017/6/13.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "NSData+ImageContentType.h"

@implementation NSData (ImageContentType)

+ (ImageFormat)imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return ImageFormatUndefined;
    }
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return ImageFormatJPEG;
        case 0x89:
            return ImageFormatPNG;
        case 0x47:
            return ImageFormatGIF;
        case 0x49:
        case 0x4D:
            return ImageFormatTIFF;
        case 0x52:
            if (data.length < 12) {
                return ImageFormatUndefined;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return ImageFormatWebP;
            }
    }
    return ImageFormatUndefined;
}

@end

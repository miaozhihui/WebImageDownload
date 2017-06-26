//
//  NSData+ImageContentType.h
//  Download
//
//  Created by miaozhihui on 2017/6/13.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ImageFormat) {
    ImageFormatUndefined = -1,
    ImageFormatJPEG = 0,
    ImageFormatPNG,
    ImageFormatGIF,
    ImageFormatTIFF,
    ImageFormatWebP
};

@interface NSData (ImageContentType)

/**
 根据输入的图片二进制数据返回图片格式

 @param data 输入二进制数据
 @return 图片格式
 */
+ (ImageFormat)imageFormatForImageData:(nullable NSData *)data;

@end

//
//  UIImage+MultiFormat.h
//  Download
//
//  Created by miaozhihui on 2017/6/13.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSData+ImageContentType.h"

@interface UIImage (MultiFormat)

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data;
- (nullable NSData *)imageData;
- (nullable NSData *)imageDataAsFormat:(ImageFormat)imageFormat;

@end

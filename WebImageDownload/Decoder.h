//
//  UIImage+Decoder.h
//  Download
//
//  Created by miaozhihui on 2017/5/24.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Compat.h"

@interface UIImage (Decoder)

+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image;

+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image;

@end

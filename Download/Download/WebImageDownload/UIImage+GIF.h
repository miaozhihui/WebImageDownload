//
//  UIImage+GIF.h
//  Download
//
//  Created by miaozhihui on 2017/6/13.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

+ (nullable UIImage *)animatedGIFWithData:(nullable NSData *)data;

- (BOOL)isGIF;

@end

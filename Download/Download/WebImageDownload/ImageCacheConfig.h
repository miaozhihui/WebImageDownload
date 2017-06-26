//
//  ImageCacheConfig.h
//  Download
//
//  Created by miaozhihui on 2017/6/9.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Compat.h"

@interface ImageCacheConfig : NSObject

/**
 是否解压图片(默认YES)
 */
@property (nonatomic, assign) BOOL shouldDecompressImages;

/**
 是否关闭云备份(默认YES)
 */
@property (nonatomic, assign) BOOL shouldDisableiCloud;

/**
 是否使用内存缓存图片(默认YES)
 */
@property (nonatomic, assign) BOOL shouldCacheImagesInMemory;

/**
 图片在内存中的最大保持时间(单位秒)
 */
@property (nonatomic, assign) NSInteger maxCacheAge;

/**
 最大缓存大小(单位字节)
 */
@property (nonatomic, assign) NSUInteger maxCacheSize;

@end

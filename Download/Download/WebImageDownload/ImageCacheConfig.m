//
//  ImageCacheConfig.m
//  Download
//
//  Created by miaozhihui on 2017/6/9.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "ImageCacheConfig.h"

static const NSInteger KDefaultCacheMaxCacheAge = 60 * 60 * 24 *7; // 一周

@implementation ImageCacheConfig

- (instancetype)init {
    if (self = [super init]) {
        _shouldDecompressImages = YES;
        _shouldDisableiCloud = YES;
        _shouldCacheImagesInMemory = YES;
        _maxCacheAge = KDefaultCacheMaxCacheAge;
        _maxCacheSize = 0;
    }
    return self;
}

@end

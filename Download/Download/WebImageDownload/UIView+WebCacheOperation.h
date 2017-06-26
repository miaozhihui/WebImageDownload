//
//  UIView+WebCacheOperation.h
//  Download
//
//  Created by miaozhihui on 2017/6/19.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Compat.h"

#if SD_UIKIT || SD_MAC

#import "WebImageManager.h"

@interface UIView (WebCacheOperation)

- (void)setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key;

- (void)cancelImageLoadOperationWithKey:(nullable NSString *)key;

- (void)removeImageLoadOperationWithKey:(nullable NSString *)key;

@end

#endif

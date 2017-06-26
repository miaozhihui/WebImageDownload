//
//  UIView+WebCache.h
//  Download
//
//  Created by miaozhihui on 2017/6/19.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Compat.h"

#if SD_UIKIT || SD_MAC

#import "WebImageManager.h"

typedef void(^SetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

@interface UIView (WebCache)

- (nullable NSURL *)imageURL;

- (void)internalSetImageWithURL:(nullable NSURL *)url
               placeholderImage:(nullable UIImage *)placeholder
                        options:(WebImageOptions)options
                   operationKey:(nullable NSString *)operationKey
                  setImageBlock:(nullable SetImageBlock)setImageBlock
                       progress:(nullable DownloaderProgressBlock)progressBlock
                      completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)cancelCurrentImageLoad;

#if SD_UIKIT

- (void)setShowActivityIndicatorView:(BOOL)show;

- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (BOOL)showActivityIndicatorView;

- (void)addActivityIndicator;

- (void)removeActivityIndicator;

#endif

@end

#endif

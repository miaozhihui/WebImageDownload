//
//  UIImageView+WebCache.h
//  Download
//
//  Created by miaozhihui on 2017/6/19.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Compat.h"

#if SD_UIKIT || SD_MAC

#import "WebImageManager.h"

@interface UIImageView (WebCache)

- (void)setImageWithURL:(nullable NSURL *)url;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options;

- (void)setImageWithURL:(nullable NSURL *)url
              completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
              completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options
              completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options
               progress:(nullable DownloaderProgressBlock)progressBlock
              completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setImageWithPreviousCachedImageWithURL:(nullable NSURL *)url
                              placeholderImage:(nullable UIImage *)placeholder
                                       options:(WebImageOptions)options
                                      progress:(nullable DownloaderProgressBlock)progressBlock
                                     completed:(nullable ExternalCompletionBlock)completedBlock;

#if SD_UIKIT

- (void)setAnimationImagesWithURLs:(nonnull NSArray<NSURL *> *)arrayOfURLs;

- (void)cancelCurrentAnimationImagesLoad;

#endif

@end

#endif

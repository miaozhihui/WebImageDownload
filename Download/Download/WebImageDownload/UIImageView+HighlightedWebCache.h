//
//  UIImageView+HighlightedWebCache.h
//  Download
//
//  Created by miaozhihui on 2017/6/21.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Compat.h"

#if SD_UIKIT

#import "WebImageManager.h"

@interface UIImageView (HighlightedWebCache)

- (void)setHighlightedImageWithURL:(nullable NSURL *)url;

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                           options:(WebImageOptions)options;

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                         completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                           options:(WebImageOptions)options
                         completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                           options:(WebImageOptions)options
                          progress:(nullable DownloaderProgressBlock)progressBlock
                         completed:(nullable ExternalCompletionBlock)completedBlock;

@end

#endif

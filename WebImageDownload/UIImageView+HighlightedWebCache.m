//
//  UIImageView+HighlightedWebCache.m
//  Download
//
//  Created by miaozhihui on 2017/6/21.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "UIImageView+HighlightedWebCache.h"

#if SD_UIKIT

#import "UIView+WebCacheOperation.h"
#import "UIView+WebCache.h"

@implementation UIImageView (HighlightedWebCache)

- (void)setHighlightedImageWithURL:(nullable NSURL *)url {
    [self setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                           options:(WebImageOptions)options {
    [self setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                         completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                           options:(WebImageOptions)options
                         completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)setHighlightedImageWithURL:(nullable NSURL *)url
                           options:(WebImageOptions)options
                          progress:(nullable DownloaderProgressBlock)progressBlock
                         completed:(nullable ExternalCompletionBlock)completedBlock {
    __weak typeof(self) weakSelf = self;
    [self internalSetImageWithURL:url
                 placeholderImage:nil
                          options:options
                     operationKey:@"UIImageViewImageOperationHighlighted"
                    setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
                        weakSelf.highlightedImage = image;
                    }
                         progress:progressBlock
                        completed:completedBlock];
}

@end

#endif

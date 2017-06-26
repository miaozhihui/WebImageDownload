//
//  UIImageView+WebCache.m
//  Download
//
//  Created by miaozhihui on 2017/6/19.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "UIImageView+WebCache.h"

#if SD_UIKIT || SD_MAC

#import "UIView+WebCacheOperation.h"
#import "UIView+WebCache.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(nullable NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
              completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
              completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options
              completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(nullable NSURL *)url
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options
               progress:(nullable DownloaderProgressBlock)progressBlock
              completed:(nullable ExternalCompletionBlock)completedBlock {
    [self internalSetImageWithURL:url
                 placeholderImage:placeholder
                          options:options
                     operationKey:nil
                    setImageBlock:nil
                         progress:progressBlock
                        completed:completedBlock];
}

- (void)setImageWithPreviousCachedImageWithURL:(nullable NSURL *)url
                              placeholderImage:(nullable UIImage *)placeholder
                                       options:(WebImageOptions)options
                                      progress:(nullable DownloaderProgressBlock)progressBlock
                                     completed:(nullable ExternalCompletionBlock)completedBlock {
    NSString *key = [[WebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[ImageCache sharedImageCache] imageFromCacheForKey:key];
    [self setImageWithURL:url
         placeholderImage:lastPreviousCachedImage ?:placeholder
                  options:options
                 progress:progressBlock
                completed:completedBlock];
}

#if SD_UIKIT

- (void)setAnimationImagesWithURLs:(nonnull NSArray<NSURL *> *)arrayOfURLs {
    [self cancelCurrentAnimationImagesLoad];
    __weak __typeof(self) wself = self;
    NSMutableArray<id<Operation>> *operationsArray = [[NSMutableArray alloc] init];
    for (NSURL *logoImageURL in arrayOfURLs) {
        id <Operation> operation = [WebImageManager.sharedManager loadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, ImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!wself) return ;
            dispatch_main_async_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray<UIImage *> *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];
                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }
    [self setImageLoadOperation:operationsArray forKey:@"UIImageViewAnimationImages"];
}

- (void)cancelCurrentAnimationImagesLoad {
    [self cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

#endif

@end

#endif

//
//  UIButton+WebCache.h
//  Download
//
//  Created by miaozhihui on 2017/6/22.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Compat.h"

#if SD_UIKIT

#import "WebImageManager.h"

@interface UIButton (WebCache)

- (nullable NSURL *)currentImageURL;

- (nullable NSURL *)imageURLForState:(UIControlState)state;

#pragma mark - Image

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state;

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder;

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options;

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
              completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
              completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options
              completed:(nullable ExternalCompletionBlock)completedBlock;

#pragma mark - Background image

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state;

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder;

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                          options:(WebImageOptions)options;

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                        completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                        completed:(nullable ExternalCompletionBlock)completedBlock;

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                          options:(WebImageOptions)options
                        completed:(nullable ExternalCompletionBlock)completedBlock;

#pragma mark - Cancel

- (void)cancelImageLoadForState:(UIControlState)state;

- (void)cancelBackgroundImageLoadForState:(UIControlState)state;

@end

#endif

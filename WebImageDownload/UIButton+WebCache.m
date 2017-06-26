//
//  UIButton+WebCache.m
//  Download
//
//  Created by miaozhihui on 2017/6/22.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "UIButton+WebCache.h"

#if SD_UIKIT

#import <objc/runtime.h>
#import "UIView+WebCacheOperation.h"
#import "UIView+WebCache.h"

static char imageURLStorageKey;

typedef NSMutableDictionary<NSNumber *, NSURL *> StateImageURLDictionary;

@implementation UIButton (WebCache)

- (nullable NSURL *)currentImageURL {
    NSURL *url = self.imageURLStorage[@(self.state)];
    if (!url) {
        url = self.imageURLStorage[@(UIControlStateNormal)];
    }
    return url;
}

- (nullable NSURL *)imageURLForState:(UIControlState)state {
    return self.imageURLStorage[@(state)];
}

#pragma mark - Image

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state {
    [self setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder {
    [self setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options {
    [self setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
              completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
              completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)setImageWithURL:(nullable NSURL *)url
               forState:(UIControlState)state
       placeholderImage:(nullable UIImage *)placeholder
                options:(WebImageOptions)options
              completed:(nullable ExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.imageURLStorage removeObjectForKey:@(state)];
        return;
    }
    self.imageURLStorage[@(state)] = url;
    __weak typeof(self) weakSelf = self;
    [self internalSetImageWithURL:url
                 placeholderImage:placeholder
                          options:options
                     operationKey:[NSString stringWithFormat:@"UIButtonImageOperation%@",@(state)]
                    setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
                        [weakSelf setImage:image forState:state];
                    }
                         progress:nil
                        completed:completedBlock];
}

#pragma mark - Background image

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state {
    [self setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder {
    [self setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                          options:(WebImageOptions)options {
    [self setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                        completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                        completed:(nullable ExternalCompletionBlock)completedBlock {
    [self setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)setBackgroundImageWithURL:(nullable NSURL *)url
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholder
                          options:(WebImageOptions)options
                        completed:(nullable ExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.imageURLStorage removeObjectForKey:@(state)];
        return;
    }
    self.imageURLStorage[@(state)] = url;
    __weak typeof(self) weakSelf = self;
    [self internalSetImageWithURL:url
                 placeholderImage:placeholder
                          options:options
                     operationKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@",@(state)]
                    setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
                        [weakSelf setBackgroundImage:image forState:state];
                    }
                         progress:nil
                        completed:completedBlock];
}

- (void)cancelImageLoadForState:(UIControlState)state {
    [self cancelImageLoadOperationWithKey:[NSString stringWithFormat:@"UIButtonImageOperation%@",@(state)]];
}

- (void)cancelBackgroundImageLoadForState:(UIControlState)state {
    [self cancelImageLoadOperationWithKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@",@(state)]];
}

- (StateImageURLDictionary *)imageURLStorage {
    StateImageURLDictionary *storage = objc_getAssociatedObject(self, &imageURLStorageKey);
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &imageURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return storage;
}

@end

#endif

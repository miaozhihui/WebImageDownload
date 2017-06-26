//
//  WebImageManager.h
//  Download
//
//  Created by miaozhihui on 2017/6/15.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Compat.h"
#import "Operation.h"
#import "Downloader.h"
#import "ImageCache.h"

typedef NS_OPTIONS(NSUInteger, WebImageOptions) {
    /**
     * 失败重试
     */
    WebImageRetryFailed = 1 << 0,
    /**
     * 低优先级
     */
    WebImageLowPriority = 1 << 1,
    /**
     * 只开启内存缓存
     */
    WebImageCacheMemoryOnly = 1 << 2,
    /**
     * 渐进下载
     */
    WebImageProgressiveDownload = 1 << 3,
    /**
     * 刷新缓存
     */
    WebImageRefreshCached = 1 << 4,
    /**
     * 后台继续
     */
    WebImageContinueInBackground = 1 << 5,
    /**
     * 处理 Cookies
     */
    WebImageHandleCookies = 1 << 6,
    /**
     * 允许无效的 SSL 证书
     */
    WebImageAllowInvalidSSLCertificates = 1 << 7,
    /**
     * 高优先级
     */
    WebImageHighPriority = 1 << 8,
    /**
     * 延迟占位图片
     */
    WebImageDelayPlaceholder = 1 << 9,
    /**
     * 转换动画图片
     */
    WebImageTransformAnimatedImage = 1 << 10,
    /**
     * 手动设置图片
     */
    WebImageAvoidAutoSetImage = 1 << 11,
    /**
     * 缩小大图(不能和渐进下载同时使用)
     */
    WebImageScaleDownLargeImages = 1 << 12
};

typedef void(^ExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, ImageCacheType cacheType, NSURL * _Nullable imageURL);

typedef void(^InternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, ImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

typedef NSString * _Nullable (^WebImageCacheKeyFilterBlock)(NSURL * _Nullable url);

@class WebImageManager;

@protocol WebImageManagerDelegate <NSObject>

@optional

/**
 是否下载图片

 @param imageManager 当前 WebImageManager
 @param imageURL 下载的 URL
 */
- (BOOL)imageManager:(nonnull WebImageManager *)imageManager shouldDownloadImageForURL:(nullable NSURL *)imageURL;

/**
 转换下载的图片

 @param imageManager 当前 WebImageManager
 @param image 下载的图片
 @param imageURL 下载的 URL
 */
- (nullable UIImage *)imageManager:(nonnull WebImageManager *)imageManager
            transformDownloadImage:(nullable UIImage *)image
                           withURL:(nullable NSURL *)imageURL;

@end

@interface WebImageManager : NSObject

@property (nonatomic, weak, nullable) id <WebImageManagerDelegate> delegate;

@property (nonatomic, strong, readonly, nullable) ImageCache *imageCache;

@property (nonatomic, strong, readonly, nullable) Downloader *imageDownloader;

@property (nonatomic, copy, nullable) WebImageCacheKeyFilterBlock cacheKeyFilter;

+ (nonnull instancetype)sharedManager;

- (nonnull instancetype)initWithCache:(nonnull ImageCache *)cache downloader:(nonnull Downloader *)downloader;

- (nullable id <Operation>)loadImageWithURL:(nullable NSURL *)url
                                    options:(WebImageOptions)options
                                   progress:(nullable DownloaderProgressBlock)progressBlock
                                  completed:(nullable InternalCompletionBlock)completedBlock;

- (void)saveImageToCache:(nullable UIImage *)image forURL:(nullable NSURL *)url;

- (void)cancelAll;

- (BOOL)isRunning;

- (void)cachedImageExistsForURL:(nullable NSURL *)url completion:(nullable CheckCacheCompletionBlock)completionBlock;

- (void)diskImageExistsForURL:(nullable NSURL *)url completion:(nullable CheckCacheCompletionBlock)completionBlock;

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url;

@end

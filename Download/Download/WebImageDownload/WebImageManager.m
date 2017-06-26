//
//  WebImageManager.m
//  Download
//
//  Created by miaozhihui on 2017/6/15.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "WebImageManager.h"
#import <objc/message.h>

@interface WebImageCombinedOperation : NSObject <Operation>

@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

@property (nonatomic, copy, nullable) SDWebImageNoParamsBlock cancelBlock;

@property (nonatomic, strong, nullable) NSOperation *cacheOperation;

@end

@interface WebImageManager ()

@property (nonatomic, strong, readwrite, nonnull) ImageCache *imageCache;

@property (nonatomic, strong, readwrite, nonnull) Downloader *imageDownloader;

@property (nonatomic, strong, nonnull) NSMutableSet<NSURL *> *failedURLs;

@property (nonatomic, strong, nonnull) NSMutableArray<WebImageCombinedOperation *> *runningOperations;

@end

@implementation WebImageManager

+ (nonnull instancetype)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    ImageCache *cache = [ImageCache sharedImageCache];
    Downloader *downloader = [Downloader sharedDownloader];
    return [self initWithCache:cache downloader:downloader];
}

- (nonnull instancetype)initWithCache:(nonnull ImageCache *)cache downloader:(nonnull Downloader *)downloader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageDownloader = downloader;
        _failedURLs = [NSMutableSet new];
        _runningOperations = [NSMutableArray new];
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    } else {
        return url.absoluteString;
    }
}

- (void)cachedImageExistsForURL:(nullable NSURL *)url completion:(nullable CheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    BOOL isInMemoryCache = ([self.imageCache imageFromMemoryCacheForKey:key] != nil);
    if (isInMemoryCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES);
            }
        });
        return;
    }
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInCache) {
        if (completionBlock) {
            completionBlock(isInCache);
        }
    }];
}

- (void)diskImageExistsForURL:(nullable NSURL *)url completion:(nullable CheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInCache) {
        if (completionBlock) {
            completionBlock(isInCache);
        }
    }];
}

- (nullable id <Operation>)loadImageWithURL:(nullable NSURL *)url
                                    options:(WebImageOptions)options
                                   progress:(nullable DownloaderProgressBlock)progressBlock
                                  completed:(nullable InternalCompletionBlock)completedBlock {
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[WebImagePrefetch prefetchURLs] instead");
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    __block WebImageCombinedOperation *operation = [WebImageCombinedOperation new];
    __weak WebImageCombinedOperation *weakOperation = operation;
    BOOL isFailedUrl = NO;
    if (url) {
        @synchronized (self.failedURLs) {
            isFailedUrl = [self.failedURLs containsObject:url];
        }
    }
    if (url.absoluteString.length == 0 || (!(options & WebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
    }
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    NSString *key = [self cacheKeyForURL:url];
    operation.cacheOperation = [self.imageCache queryCacheOperationForKey:key done:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, ImageCacheType cacheType) {
        if (operation.isCancelled) {
            [self safelyRemoveOperationFromRunning:operation];
            return ;
        }
        if ((!cachedImage || options & WebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
            if (cachedImage && options & WebImageRefreshCached) {
                [self callCompletionBlockForOperation:weakOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            }
            DownloaderOptions downloaderOptions = 0;
            if (options & WebImageLowPriority) downloaderOptions |= DownloaderLowPriority;
            if (options & WebImageProgressiveDownload) downloaderOptions |= DownloaderProgressiveDownload;
            if (options & WebImageRefreshCached) downloaderOptions |= DownloaderUseNSURLCache;
            if (options & WebImageContinueInBackground) downloaderOptions |= DownloaderContinueInBackground;
            if (options & WebImageHandleCookies) downloaderOptions |= DownloaderHandleCookies;
            if (options & WebImageAllowInvalidSSLCertificates) downloaderOptions |= DownloaderAllowInvalidSSLCertificates;
            if (options & WebImageHighPriority) downloaderOptions |= DownloaderHighPriority;
            if (options & WebImageScaleDownLargeImages) downloaderOptions |= DownloaderScaleDownLargeImages;
            if (cachedImage && options & WebImageRefreshCached) {
                downloaderOptions &= ~DownloaderProgressiveDownload;
                downloaderOptions |= DownloaderIgnoreCachedResponse;
            }
            DownloadToken *subOperationToken = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage * _Nullable downloadedImage, NSData * _Nullable downloadedData, NSError * _Nullable error, BOOL finished) {
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                if (!strongOperation || strongOperation.isCancelled) {
                    
                } else if (error) {
                    [self callCompletionBlockForOperation:strongOperation completion:completedBlock error:error url:url];
                    if (error.code != NSURLErrorNotConnectedToInternet &&
                        error.code != NSURLErrorCancelled &&
                        error.code != NSURLErrorTimedOut &&
                        error.code != NSURLErrorInternationalRoamingOff &&
                        error.code != NSURLErrorDataNotAllowed &&
                        error.code != NSURLErrorCannotFindHost &&
                        error.code != NSURLErrorCannotConnectToHost) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                } else {
                    if ((options & WebImageRetryFailed)) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs removeObject:url];
                        }
                    }
                    BOOL cacheOnDisk = !(options & WebImageCacheMemoryOnly);
                    if (options & WebImageRefreshCached && cachedImage && !downloadedImage) {
                        
                    } else if (downloadedImage && (!downloadedImage.images || (options & WebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadImage:withURL:)]) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadImage:downloadedImage withURL:url];
                            if (transformedImage && finished) {
                                BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                [self.imageCache storeImage:transformedImage imageData:(imageWasTransformed ? nil : downloadedData) forKey:key toDisk:cacheOnDisk completion:nil];
                            }
                            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:transformedImage data:downloadedData error:nil cacheType:ImageCacheTypeNone finished:finished url:url];
                        });
                    } else {
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage imageData:downloadedData forKey:key toDisk:cacheOnDisk completion:nil];
                        }
                        [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:downloadedImage data:downloadedData error:nil cacheType:ImageCacheTypeNone finished:finished url:url];
                    }
                }
                if (finished) {
                    [self safelyRemoveOperationFromRunning:strongOperation];
                }
            }];
            operation.cancelBlock = ^{
                [self.imageDownloader cancel:subOperationToken];
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                [self safelyRemoveOperationFromRunning:strongOperation];
            };
        } else if (cachedImage) {
            __strong __typeof(weakOperation) strongOperation = weakOperation;
            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            [self safelyRemoveOperationFromRunning:operation];
        } else {
            __strong __typeof(weakOperation) strongOperation = weakOperation;
            [self callCompletionBlockForOperation:strongOperation completion:completedBlock image:nil data:nil error:nil cacheType:ImageCacheTypeNone finished:YES url:url];
            [self safelyRemoveOperationFromRunning:operation];
        }
    }];
    return operation;
}

- (void)saveImageToCache:(nullable UIImage *)image forURL:(nullable NSURL *)url {
    if (image && url) {
        NSString *key = [self cacheKeyForURL:url];
        [self.imageCache storeImage:image forKey:key toDisk:YES completion:nil];
    }
}

- (void)cancelAll {
    @synchronized (self.runningOperations) {
        NSArray<WebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
        [copiedOperations makeObjectsPerformSelector:@selector(cancel)];
        [self.runningOperations removeObjectsInArray:copiedOperations];
    }
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    @synchronized (self.runningOperations) {
        isRunning = (self.runningOperations.count > 0);
    }
    return isRunning;
}

- (void)safelyRemoveOperationFromRunning:(nullable WebImageCombinedOperation *)operation {
    @synchronized (self.runningOperations) {
        if (operation) {
            [self.runningOperations removeObject:operation];
        }
    }
}

- (void)callCompletionBlockForOperation:(nullable WebImageCombinedOperation *)operation
                             completion:(nullable InternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:ImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable WebImageCombinedOperation *)operation
                             completion:(nullable InternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(ImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    dispatch_main_async_safe(^{
        if (operation && !operation.isCancelled && completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

@end

@implementation WebImageCombinedOperation

- (void)setCancelBlock:(nullable SDWebImageNoParamsBlock)cancelBlock {
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil;
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
        _cancelBlock = nil;
    }
}

@end

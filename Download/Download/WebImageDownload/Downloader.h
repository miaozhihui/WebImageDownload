//
//  Downloader.h
//  Download
//
//  Created by miaozhihui on 2017/5/25.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Compat.h"
#import "Operation.h"

typedef NS_OPTIONS(NSUInteger, DownloaderOptions) {
    /**
     * 低优先级
     */
    DownloaderLowPriority = 1 << 0,
    /**
     * 渐进下载
     */
    DownloaderProgressiveDownload = 1 << 1,
    /**
     * 使用 NSURLCache
     */
    DownloaderUseNSURLCache = 1 << 2,
    /**
     * 忽略缓存响应
     */
    DownloaderIgnoreCachedResponse = 1 << 3,
    /**
     * 后台继续下载
     */
    DownloaderContinueInBackground = 1 << 4,
    /**
     * 处理 Cookies
     */
    DownloaderHandleCookies = 1 << 5,
    /**
     * 允许无效的 SSL 证书
     */
    DownloaderAllowInvalidSSLCertificates = 1 << 6,
    /**
     * 高优先级
     */
    DownloaderHighPriority = 1 << 7,
    /**
     * 缩小大图
     */
    DownloaderScaleDownLargeImages = 1 << 8,
};

typedef NS_ENUM(NSInteger, DownloaderExecutionOrder) {
    /**
     * 先进先出的执行顺序 默认选项
     */
    DownloaderFIFOExecutionOrder,
    /**
     * 后进先出的执行顺序
     */
    DownloaderLIFOExecutionOrder
};

extern NSString * _Nonnull const DownloadStartNotification;
extern NSString * _Nonnull const DownloadStopNotification;

typedef void(^DownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

typedef void(^DownloaderCompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished);

typedef NSDictionary<NSString *, NSString *> HTTPHeadersDictionary;
typedef NSMutableDictionary<NSString *, NSString *> HTTPHeadersMutableDictionary;

typedef HTTPHeadersDictionary * _Nullable (^DownloaderHeadersFilterBlock)(NSURL * _Nullable url, HTTPHeadersDictionary * _Nullable headers);

@interface DownloadToken : NSObject

@property (nonatomic, strong, nullable) NSURL *url;

@property (nonatomic, strong, nullable) id downloadOperationCancelToken;

@end

@interface Downloader : NSObject

/**
 是否解压图片
 */
@property (nonatomic, assign) BOOL shouldDecompressImages;

/**
 最大并发下载数
 */
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;

/**
 当前下载数量
 */
@property (nonatomic, readonly) NSUInteger currentDownloadCount;

/**
 下载超时时间
 */
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

/**
 下载执行顺序
 */
@property (nonatomic, assign) DownloaderExecutionOrder executionOrder;

/**
 证书
 */
@property (nonatomic, strong, nullable) NSURLCredential *urlCredential;

/**
 用户名
 */
@property (nonatomic, strong, nullable) NSString *username;

/**
 密码
 */
@property (nonatomic, strong, nullable) NSString *password;

/**
 过滤请求头的 Block
 */
@property (nonatomic, copy, nullable) DownloaderHeadersFilterBlock headersFilter;

/**
 下载单例
 */
+ (nonnull instancetype)sharedDownloader;

/**
 指定构造方法
 */
- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration;

/**
 为 HTTP 请求添加请求头

 @param value 请求头的值
 @param field 请求头字段
 */
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nullable NSString *)field;

/**
 获取请求头字段的值

 @param field 请求头字段
 @return 请求头字段的值
 */
- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field;

/**
 设置下载的操作类

 @param operationClass 操作类 如果传 nil 使用 DownloaderOperation
 */
- (void)setOperationClass:(nullable Class)operationClass;

/**
 下载方法

 @param url 下载图片的 URL
 @param options 下载的选项
 @param progressBlock 进度回调
 @param completedBlock 完成回调
 @return 下载令牌
 */
- (nullable DownloadToken *)downloadImageWithURL:(nullable NSURL *)url
                                         options:(DownloaderOptions)options
                                        progress:(nullable DownloaderProgressBlock)progressBlock
                                       completed:(nullable DownloaderCompletedBlock)completedBlock;

/**
 取消对应令牌的下载操作

 @param token 令牌
 */
- (void)cancel:(nullable DownloadToken *)token;

/**
 设置下载队列暂停状态

 @param suspended 是否暂停
 */
- (void)setSuspended:(BOOL)suspended;

/**
 取消下载队列里的所有下载操作
 */
- (void)cancelAllDownloads;

@end

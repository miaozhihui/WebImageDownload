//
//  DownloaderOperation.h
//  Download
//
//  Created by miaozhihui on 2017/5/23.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"
#import "Operation.h"

extern NSString * _Nonnull const DownloadStartNotification;
extern NSString * _Nonnull const DownloadReceiveResponseNotification;
extern NSString * _Nonnull const DownloadStopNotification;
extern NSString * _Nonnull const DownloadFinishNotification;

@protocol DownloaderOperationInterface <NSObject>

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(DownloaderOptions)options;

- (nullable id)addHandlersForProgress:(nullable DownloaderProgressBlock)progressBlock
                            completed:(nullable DownloaderCompletedBlock)completedBlock;

- (BOOL)shouldDecompressImages;
- (void)setShouldDecompressImages:(BOOL)value;

- (nullable NSURLCredential *)credential;
- (void)setCredential:(nullable NSURLCredential *)value;

@end

@interface DownloaderOperation : NSOperation<DownloaderOperationInterface, Operation, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

/**
 操作任务所使用的请求
 */
@property (nonatomic, strong, readonly, nullable) NSURLRequest *request;

/**
 操作任务
 */
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *dataTask;

/**
 是否解压缩图片
 */
@property (nonatomic, assign) BOOL shouldDecompressImages;

/**
 证书
 */
@property (nonatomic, strong, nullable) NSURLCredential *credential;

/**
 下载相关的选项
 */
@property (nonatomic, assign, readonly) DownloaderOptions options;

/**
 请求数据大小
 */
@property (nonatomic, assign) NSInteger expectedSize;

/**
 操作连接返回的响应
 */
@property (nonatomic, strong, nullable) NSURLResponse *response;

/**
 指定初始化方法

 @param request 下载操作请求
 @param session 下载操作运行的 session
 @param options 下载选项
 @return 实例化的下载操作
 */
- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(DownloaderOptions)options;

/**
 对下载任务添加进度和完成回调处理

 @param progressBlock 进度回调
 @param completedBlock 完成回调
 @return 标识回调操作的 token
 */
- (nullable id)addHandlersForProgress:(nullable DownloaderProgressBlock)progressBlock
                            completed:(nullable DownloaderCompletedBlock)completedBlock;

/**
 取消回调的集合，一旦所有的回调被取消，这个操作也就被取消

 @param token 一组回调取消的令牌
 @return 如果下载操作被取消，返回 YES
 */
- (BOOL)cancel:(nullable id)token;

@end

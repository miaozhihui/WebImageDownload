//
//  Downloader.m
//  Download
//
//  Created by miaozhihui on 2017/5/25.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "Downloader.h"
#import "DownloaderOperation.h"

@implementation DownloadToken

@end

@interface Downloader() <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

/**
 下载操作的队列
 */
@property (nonatomic, strong, nonnull) NSOperationQueue *downloadQueue;

/**
 最后添加的操作
 */
@property (nonatomic, weak, nullable) NSOperation *lastAddedOperation;

/**
 操作的类
 */
@property (nonatomic, assign, nullable) Class operationClass;

/**
 URL和下载操作字典
 */
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSURL *, DownloaderOperation *> *URLOperations;

/**
 HTTP请求头
 */
@property (nonatomic, strong, nullable) HTTPHeadersMutableDictionary *HTTPHeaders;

/**
 序列化所有下载操作的网络响应的队列
 */
@property (nonatomic, SDDispatchQueueSetterSementics, nullable) dispatch_queue_t barrierQueue;

/**
 下载任务运行的 Session
 */
@property (nonatomic, strong) NSURLSession *session;

@end


@implementation Downloader

+ (nonnull instancetype)sharedDownloader {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration {
    if ((self = [super init])) {
        _operationClass = [DownloaderOperation class];
        _shouldDecompressImages = YES;
        _executionOrder = DownloaderFIFOExecutionOrder;
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"com.hackemist.Downloader";
        _URLOperations = [NSMutableDictionary new];
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        _barrierQueue = dispatch_queue_create("com.hackemist.DownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;
        sessionConfiguration.timeoutIntervalForRequest = _downloadTimeout;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    
    [self.downloadQueue cancelAllOperations];
    SDDispatchQueueRelease(_barrierQueue);
}

- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nullable NSString *)field {
    if (value) {
        self.HTTPHeaders[field] = value;
    } else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
}

- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field {
    return self.HTTPHeaders[field];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (void)setOperationClass:(Class)operationClass {
    if (operationClass && [operationClass isSubclassOfClass:[NSOperation class]] && [operationClass conformsToProtocol:@protocol(DownloaderOperationInterface)]) {
        _operationClass = operationClass;
    } else {
        _operationClass = [DownloaderOperation class];
    }
}

- (nullable DownloadToken *)downloadImageWithURL:(nullable NSURL *)url
                                         options:(DownloaderOptions)options
                                        progress:(nullable DownloaderProgressBlock)progressBlock
                                       completed:(nullable DownloaderCompletedBlock)completedBlock {
    __weak Downloader *wself = self;
    return [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^DownloaderOperation *{
        __strong typeof(wself) sself = wself;
        NSTimeInterval timeoutInterval = sself.downloadTimeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 15.0;
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(options & DownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:timeoutInterval];
        request.HTTPShouldHandleCookies = (options & DownloaderHandleCookies);
        request.HTTPShouldUsePipelining = YES;
        if (sself.headersFilter) {
            request.allHTTPHeaderFields = sself.headersFilter(url, [sself.HTTPHeaders copy]);
        } else {
            request.allHTTPHeaderFields = sself.HTTPHeaders;
        }
        DownloaderOperation *operation = [[sself.operationClass alloc] initWithRequest:request inSession:sself.session options:options];
        operation.shouldDecompressImages = sself.shouldDecompressImages;
        
        if (sself.urlCredential) {
            operation.credential = sself.urlCredential;
        } else if (sself.username && sself.password) {
            operation.credential = [NSURLCredential credentialWithUser:sself.username password:sself.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        if (options & DownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & DownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }
        
        [sself.downloadQueue addOperation:operation];
        if (sself.executionOrder == DownloaderLIFOExecutionOrder) {
            [sself.lastAddedOperation addDependency:operation];
            sself.lastAddedOperation = operation;
        }
        return operation;
    }];
}

- (nullable DownloadToken *)addProgressCallback:(DownloaderProgressBlock)progressBlock
                                 completedBlock:(DownloaderCompletedBlock) completedBlock
                                         forURL:(nullable NSURL *)url
                                 createCallback:(DownloaderOperation *(^)())createCallback {
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, nil, NO);
        }
        return nil;
    }
    __block DownloadToken *token = nil;
    dispatch_barrier_sync(self.barrierQueue, ^{
        DownloaderOperation *operation = self.URLOperations[url];
        if (!operation) {
            operation = createCallback();
            self.URLOperations[url] = operation;
            __weak DownloaderOperation *woperation = operation;
            operation.completionBlock = ^{
                DownloaderOperation *soperation = woperation;
                if (!soperation) return ;
                if (self.URLOperations[url] == soperation) {
                    [self.URLOperations removeObjectForKey:url];
                }
            };
        }
        id downloadOperationCancelToken = [operation addHandlersForProgress:progressBlock completed:completedBlock];
        token = [DownloadToken new];
        token.url = url;
        token.downloadOperationCancelToken = downloadOperationCancelToken;
    });
    return token;
}

- (void)cancel:(nullable DownloadToken *)token {
    dispatch_barrier_async(self.barrierQueue, ^{
        DownloaderOperation *operation = self.URLOperations[token.url];
        BOOL canceled = [operation cancel:token.downloadOperationCancelToken];
        if (canceled) {
            [self.URLOperations removeObjectForKey:token.url];
        }
    });
}

- (void)setSuspended:(BOOL)suspended {
    self.downloadQueue.suspended = suspended;
}

- (void)cancelAllDownloads {
    [self.downloadQueue cancelAllOperations];
}

#pragma mark Helper methods

- (DownloaderOperation *)operationWithTask:(NSURLSessionTask *)task {
    DownloaderOperation *returnOperation = nil;
    for (DownloaderOperation *operation in self.downloadQueue.operations) {
        if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
            returnOperation = operation;
            break;
        }
    }
    return returnOperation;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    DownloaderOperation *dataOperation = [self operationWithTask:dataTask];
    [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    DownloaderOperation *dataOperation = [self operationWithTask:dataTask];
    [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    DownloaderOperation *dataOperation = [self operationWithTask:dataTask];
    [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    DownloaderOperation *dataOperation = [self operationWithTask:task];
    [dataOperation URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    DownloaderOperation *dataOperation = [self operationWithTask:task];
    [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

@end

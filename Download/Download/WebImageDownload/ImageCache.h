//
//  ImageCache.h
//  Download
//
//  Created by miaozhihui on 2017/6/9.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Compat.h"

@class ImageCacheConfig;

typedef NS_ENUM(NSInteger, ImageCacheType) {
    /**
     * 不使用缓存，从网络下载
     */
    ImageCacheTypeNone,
    /**
     * 从硬盘缓存获取
     */
    ImageCacheTypeDisk,
    /**
     * 从内存缓存获取
     */
    ImageCacheTypeMemory
};

typedef void(^CacheQueryCompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data, ImageCacheType cacheType);
typedef void(^CheckCacheCompletionBlock)(BOOL isInCache);
typedef void(^CalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);

@interface ImageCache : NSObject

#pragma mark - Properties

/**
 缓存配置对象
 */
@property (nonatomic, nonnull, readonly) ImageCacheConfig *config;

/**
 最大内存
 */
@property (nonatomic, assign) NSUInteger maxMemoryCost;

/**
 最大内存数限制
 */
@property (nonatomic, assign) NSUInteger maxMemoryCountLimit;

#pragma mark - Singleton and initialization

/**
 单例对象
 */
+ (nonnull instancetype)sharedImageCache;

/**
 用指定命名空间初始化对象

 @param ns 命名空间
 */
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns;

/**
 用指定命名空间和硬盘缓存目录初始化对象

 @param ns 命名空间
 @param directory 硬盘缓存目录
 */
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nonnull NSString *)directory;

#pragma mark - Cache paths

- (nullable NSString *)makeDiskCachePath:(nonnull NSString *)fullNamespace;

- (void)addReadOnlyCachePath:(nonnull NSString *)path;

#pragma mark - Store Ops

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
        completion:(nullable SDWebImageNoParamsBlock)completionBlock;

- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable SDWebImageNoParamsBlock)completionBlock;

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable SDWebImageNoParamsBlock)completionBlock;

- (void)storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key;

#pragma mark - Query and Retrieve Ops

- (void)diskImageExistsWithKey:(nullable NSString *)key
                    completion:(nullable CheckCacheCompletionBlock)completionBlock;

- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key
                                               done:(nullable CacheQueryCompletedBlock)doneBlock;

- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key;

- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key;

- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key;

#pragma mark - Remove Ops

- (void)removeImageForKey:(nullable NSString *)key
           withCompletion:(nullable SDWebImageNoParamsBlock)completion;

- (void)removeImageForKey:(nullable NSString *)key
                 fromDisk:(BOOL)fromDisk
           withCompletion:(nullable SDWebImageNoParamsBlock)completion;

#pragma mark - Cache clean Ops

- (void)clearMemory;

- (void)clearDiskOnCompletion:(nullable SDWebImageNoParamsBlock)completion;

- (void)deleteOldFilesWithCompletionBlock:(nullable SDWebImageNoParamsBlock)completionBlock;

#pragma mark - Cache Info

- (NSUInteger)getSize;

- (NSUInteger)getDiskCount;

- (void)calculateSizeWithCompletionBlock:(nullable CalculateSizeBlock)completionBlock;

#pragma mark - Cache Paths

- (nullable NSString *)cachePathForKey:(nullable NSString *)key
                                inPath:(nonnull NSString *)path;

- (nullable NSString *)defaultCachePathForKey:(nullable NSString *)key;

@end

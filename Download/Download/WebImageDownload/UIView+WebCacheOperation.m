//
//  UIView+WebCacheOperation.m
//  Download
//
//  Created by miaozhihui on 2017/6/19.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "UIView+WebCacheOperation.h"

#if SD_UIKIT || SD_MAC

#import <objc/runtime.h>

static char loadOperationKey;

typedef NSMutableDictionary<NSString *, id> OperationsDictionary;

@implementation UIView (WebCacheOperation)

- (OperationsDictionary *)operationDictionary {
    OperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key {
    if (key) {
        [self cancelImageLoadOperationWithKey:key];
        if (operation) {
            OperationsDictionary *operationDictionary = [self operationDictionary];
            operationDictionary[key] = operation;
        }
    }
}

- (void)cancelImageLoadOperationWithKey:(nullable NSString *)key {
    OperationsDictionary *operationDictionary = [self operationDictionary];
    id operations = operationDictionary[key];
    if (operations) {
        if ([operations isKindOfClass:NSArray.class]) {
            for (id <Operation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(Operation)]) {
            [(id<Operation>)operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        OperationsDictionary *operationDictionary = [self operationDictionary];
        [operationDictionary removeObjectForKey:key];
    }
}

@end

#endif

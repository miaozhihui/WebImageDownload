//
//  ViewController.m
//  Download
//
//  Created by miaozhihui on 2017/5/23.
//  Copyright © 2017年 DeKuTree. All rights reserved.
//

#import "ViewController.h"
#import "Downloader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Downloader *load = [Downloader sharedDownloader];
    load.shouldDecompressImages = YES;
    load.maxConcurrentDownloads = 2;
    load.downloadTimeout = 10;
    load.executionOrder = DownloaderLIFOExecutionOrder;
    DownloadToken *token = [load downloadImageWithURL:[NSURL URLWithString:@"http://t1.niutuku.com/190/14/14-117639.jpg"] options:DownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"接收数据:%d 总数据:%d",receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        NSLog(@"下载的图片:%@ 下载的数据:%@ 错误信息:%@ 是否完成:%@",image,data,error,(finished ? @"完成" :@"未完成"));
    }];
    
    
    
}


@end

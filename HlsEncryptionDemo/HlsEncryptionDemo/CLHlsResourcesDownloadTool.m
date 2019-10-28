//
//  CLHlsResourcesDownloadTool.m
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import "CLHlsResourcesDownloadTool.h"

@interface CLHlsResourcesDownloadTool ()

@property (nonatomic, copy) void(^progressBlock)(float progress);

@property (nonatomic, copy) void(^completeBlock)(BOOL successd,NSString *path,NSError *error);


@end


@implementation CLHlsResourcesDownloadTool

+ (instancetype)defaultManager {
    
    static dispatch_once_t onceToken;
    static CLHlsResourcesDownloadTool * tool = nil;
    dispatch_once(&onceToken, ^{
        tool = [[CLHlsResourcesDownloadTool alloc]init];
    });
    return tool;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration * backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"AAPL-Identifier"];
        self.downLoadSession = [AVAssetDownloadURLSession sessionWithConfiguration:backgroundConfiguration assetDownloadDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}
-(void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didLoadTimeRange:(CMTimeRange)timeRange totalTimeRangesLoaded:(NSArray<NSValue *> *)loadedTimeRanges timeRangeExpectedToLoad:(CMTimeRange)timeRangeExpectedToLoad {
    float percentComplete = 0.0 ;
    for (NSValue * value in loadedTimeRanges) {
        CMTimeRange rang = [value CMTimeRangeValue];
        percentComplete += rang.duration.value * 1.0/timeRangeExpectedToLoad.duration.value;
        
    }
    if (self.progressBlock) {
        self.progressBlock(percentComplete);
    }
    percentComplete *= 100;
    NSLog(@"更新下载进度%f",percentComplete);
    
    
}
- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"下载完成 %@",location);
    if (self.completeBlock) {
        self.completeBlock(YES, location.relativePath, nil);
    }
}

- (void)URLSession:(NSURLSession *)session assetDownloadTask:(AVAssetDownloadTask *)assetDownloadTask didResolveMediaSelection:(AVMediaSelection *)resolvedMediaSelection {

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"下载失败 %@",error);
    if (error && self.completeBlock) {
         self.completeBlock(NO, nil,error);
    }
   
}
- (void)dowloadHlsAsset:(AVURLAsset *)asset progressBlock:(void(^)(float progress))progressBlock completeBlock:(void(^)(BOOL successd,NSString *path,NSError *error))completeBlock {
    [self setProgressBlock:progressBlock];
    [self setCompleteBlock:completeBlock];
    self.downLoadTask =  [self.downLoadSession assetDownloadTaskWithURLAsset:asset assetTitle:@"AAPL-Identifier" assetArtworkData:nil options:nil];
    [self.downLoadTask resume];
}

@end

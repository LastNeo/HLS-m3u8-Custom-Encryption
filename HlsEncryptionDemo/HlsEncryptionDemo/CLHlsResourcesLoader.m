//
//  CLHlsResourcesLoader.m
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import "CLHlsResourcesLoader.h"
#import "AFNetworking.h"
#define WEAKSELF typeof(self) __weak weakSelf = self;
@interface CLHlsResourcesLoader ()

@property (nonatomic, strong) NSString * m3u8_url;
@property (nonatomic, strong) NSString * m3u8_url_vir;
@end


@implementation CLHlsResourcesLoader
+ (CLHlsResourcesLoader *)shared {
    static CLHlsResourcesLoader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone: nil] init];
    });
    return instance;
}

- (CLHlsResourcesLoader *)init {
    self = [super init];
    _m3u8_url_vir = @"m3u8Scheme://error.m3u8";
    return self;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSString *url = [[[loadingRequest request] URL] absoluteString];
    if (!url) {
        return false;
    }
    //第三步.ts请求的链接是在基础链接的域名后拼接的 因为一开始替换了M3u8请求的域名，所以这里在替换回正常的要请求的域名就可以了
    if ([url hasSuffix: @".ts"]) {
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * requestUrl =  [NSURL URLWithString:weakSelf.m3u8_url];
            NSString *newUrl = [NSString stringWithFormat:@"http://%@",[url stringByReplacingOccurrencesOfString: self.m3u8_url_vir withString: requestUrl.host]] ;
            NSURL *url = [[NSURL alloc] initWithString: newUrl];
            if (url) {
                NSURLRequest *redirect = [[NSURLRequest alloc] initWithURL: url];
                [loadingRequest setRedirect: redirect];
                [loadingRequest setResponse: [[NSHTTPURLResponse alloc] initWithURL: [redirect URL] statusCode: 301 HTTPVersion: nil headerFields: nil]];
                [loadingRequest finishLoading];
            } else {
                [self finishLoadingError: loadingRequest];
            }
        });
        return true;
    }
    //第一步修改M3u8文件的头文件来重定向key链接,这里也可以做一些链接解密，或者拼接请求key的链接
    if ([url isEqualToString: _m3u8_url_vir]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [self M3u8Request: self->_m3u8_url];
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[loadingRequest dataRequest] respondWithData: data];
                    [loadingRequest finishLoading];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self finishLoadingError: loadingRequest];
                });
            }
        });
        return true;
    }
   //第二步自己请求M3u8内部的key,去除多余的\n,然后将请求到的数据返回给系统，系统会自动根据你给他的key 来解析AES-128加密过的数据，这里也可以做一些拼接key或者二次解密key
    if (![url hasSuffix: @".ts"] && ![url isEqualToString: _m3u8_url_vir]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   NSData *data = [self KeyRequest:url];
                   if (data) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           //这里存储钥匙串主要给下载本地后播放用的，存储的key我写死了，可以替换为请求链接的 md5值作为标记
                           [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"localKey"];
                           loadingRequest.contentInformationRequest.contentType = AVStreamingKeyDeliveryPersistentContentKeyType;
                           [[loadingRequest dataRequest] respondWithData: data];
                           [loadingRequest finishLoading];
                       });
                   } else {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self finishLoadingError: loadingRequest];
                       });
                   }
               });
        return true;
    }
    return false;
}

- (void)finishLoadingError: (AVAssetResourceLoadingRequest *)loadingRequest {
    [loadingRequest finishLoadingWithError: [[NSError alloc] initWithDomain: NSURLErrorDomain code: 400 userInfo: nil]];
}

- (NSData *)M3u8Request: (NSString *)url {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    static NSData *result = NULL;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //返回一个下载任务对象
    NSURLSessionDownloadTask *loadTask = [manager downloadTaskWithRequest:requset progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%lld----%lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *fullPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:response.suggestedFilename];
        NSLog(@"targetPath-：%@---fullPath:-%@",targetPath,fullPath);
        
        //这个block 需要返回一个目标 地址 存储下载的文件
        return  [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //这里将M3u8里的请求key的方法换成错误的链接方便重定向
        NSString * string =  [NSString stringWithContentsOfURL:filePath encoding:(NSUTF8StringEncoding) error:nil];
        NSString * newString  = [string stringByReplacingOccurrencesOfString:@"http" withString:@"ckey"];
        result = [newString dataUsingEncoding:NSUTF8StringEncoding];
                dispatch_semaphore_signal(semaphore);
        NSLog(@"下载完成地址:%@",filePath);
        
    }];
    [loadTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

- (NSData *)playDataRequest:(NSString *)url {
       dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
       static NSData *result = NULL;
      NSString *newUrl = [url stringByReplacingOccurrencesOfString: @"ckey" withString: @"http"];
       AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
       NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]];
       //返回一个下载任务对象
       NSURLSessionDownloadTask *loadTask = [manager downloadTaskWithRequest:requset progress:^(NSProgress * _Nonnull downloadProgress) {
           NSLog(@"%lld----%lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
       } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
           NSString *fullPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:response.suggestedFilename];
           NSLog(@"targetPath-：%@---fullPath:-%@",targetPath,fullPath);
           return  [NSURL fileURLWithPath:fullPath];
       } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
          NSString * string =  [NSString stringWithContentsOfURL:filePath encoding:(NSUTF8StringEncoding) error:nil];
            NSString * newString  = [string stringByReplacingOccurrencesOfString:@"http" withString:@"ckey"];
           result = [newString dataUsingEncoding:NSUTF8StringEncoding];
           dispatch_semaphore_signal(semaphore);
           NSLog(@"下载完成地址:%@",filePath);
           
       }];
       [loadTask resume];
       dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
       return result;
}
- (NSData *)KeyRequest: (NSString *)url {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    static NSData *result = NULL;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
     NSString *newUrl = [url stringByReplacingOccurrencesOfString: @"ckey" withString: @"http"];
    NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]];
    //返回一个下载任务对象
    NSURLSessionDownloadTask *loadTask = [manager downloadTaskWithRequest:requset progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%lld----%lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *fullPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:response.suggestedFilename];
        NSLog(@"targetPath-：%@---fullPath:-%@",targetPath,fullPath);
        //这个block 需要返回一个目标 地址 存储下载的文件
        return  [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSString * string =  [NSString stringWithContentsOfURL:filePath encoding:(NSUTF8StringEncoding) error:nil];
        NSString * newString  = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        result = [newString dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_semaphore_signal(semaphore);
        NSLog(@"下载完成地址:%@",filePath);
        
    }];
    [loadTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

- (AVPlayerItem *)playItemWith: (NSString *)url {
    self.m3u8_url = url;
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL: [[NSURL alloc] initWithString: self.m3u8_url_vir] options: nil];
    [[urlAsset resourceLoader] setDelegate: self queue: dispatch_get_main_queue()];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset: urlAsset];
    [item setCanUseNetworkResourcesForLiveStreamingWhilePaused: YES];
    return item;
}

- (AVURLAsset *)downLoadAssetWith:(NSString *)url {
    self.m3u8_url = url;
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL: [[NSURL alloc] initWithString: self.m3u8_url_vir] options: nil];
    [[urlAsset resourceLoader] setDelegate: self queue: dispatch_get_main_queue()];
    return urlAsset;
}

@end

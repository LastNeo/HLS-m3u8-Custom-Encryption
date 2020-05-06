# HLS-m3u8-Custom-Encryption
# iOSHLS  M3U8 自定义AES-128钥匙串或链接解密流程（播放，下载，下载本地后播放）(求个⭐️🥺)
# 如果显示下载失败，请在真机上运行！！！如果显示下载失败，请在真机上运行！！！如果显示下载失败，请在真机上运行！！！

其实理论上来说苹果支持原生直接播放 AES-128加密的，只要符合苹果的加密标准但是在实际使用过程中，因为有安卓、H5、或者基于已有的接口数据，或是想要自定义钥匙串保密方式，在或者想要加密播放加密链接，加密钥匙串链接，基于以上的种种要求，直接用AVPlay 显然不能满足所有的要求，所以苹果在加入了一个新的Api 用来重定向播放链接。

网上对于HLS 加密的资料比较少，尤其是对加密过后的HLS 链接本地下载，本地播放就更少了，我也是摸着石头过河，这些是我总结的一些资料，和我自己整个的学习过程

### 1、基础篇:如何播放未加密的HLS M3U8 音频或视频

以下我以音频举例子视频其实一样就是把AVPlayer 的layer 加到View上，网上的例子很多不做赘述

我用的七牛的链接作为测试链接理论来说只要你的播放链接能直接放到safri上播放，那么用AVPlayer也可以正常播放

``` 
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL URLWithString:@"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"]];
    AVPlayerItem * item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer * player = [AVPlayer playerWithPlayerItem:item];
    [player play];    

```

那么看下未加密的M3u8数据的内容格式

``` 
#EXTM3U
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=232370,CODECS="mp4a.40.2, avc1.4d4015"
gear1/prog_index.m3u8

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=649879,CODECS="mp4a.40.2, avc1.4d401e"
gear2/prog_index.m3u8

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=991714,CODECS="mp4a.40.2, avc1.4d401e"
gear3/prog_index.m3u8

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1927833,CODECS="mp4a.40.2, avc1.4d401f"
gear4/prog_index.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=41457,CODECS="mp4a.40.2"
gear0/prog_index.m3u8   

```
音频头包含播放的链接和内容AVPlayer会自动匹配

### 2、进阶篇:如何播放加密的HLS M3U8 音频或视频
其实加密和未加密的区别主要在于头文件的不同
这个是有关苹果对于标准HLS链接的要求
https://developer.apple.com/documentation/http_live_streaming/about_the_common_media_application_format_with_http_live_streaming?language=objc

如果是标准加密的AVPlayer支持原生播放与上面的播放方式相同
以下我将介绍如何播放非标准加密:例如你的密匙是服务保存一部分本地一部分，或者你的key是加密的钥匙串 
这里我以七牛链接作为例子 

``` 
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-ALLOW-CACHE:YES
#EXT-X-TARGETDURATION:11
#EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key",IV=0xb279c05ae6a3d0ffd45da748cf305dd9
#EXTINF:10.927589,
/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R/000000.ts
#EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key",IV=0x4aec782ea1419fb7865ba5452cbd9413
#EXTINF:9.342667,
/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R/000001.ts
#EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key",IV=0xeac1912aaab5469783cbb742b9f6f534
#EXTINF:10.719044,
/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R/000002.ts
#EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key",IV=0x500f42c7a7c969f47bd8886444c2d198
#EXTINF:9.342667,
/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R/000003.ts
#EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key",IV=0x9b1b6e27eb70eb32c164bb12cde89a86
#EXTINF:10.468789,
/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R/000004.ts
#EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key",IV=0x947eba85bbefb54f364ce99b0121fbde
#EXTINF:9.300967,
/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R/000005.ts
#EXT-X-ENDLIST
```

可以看出与未加密的HLS 对比多了一个叫 #EXT-X-KEY:METHOD=AES-128,URI="http://ogtoywd4d.bkt.clouddn.com/hls128.key" 下载该链接会发现里面多个key的链接 

``` 
curl -I http://ogtoywd4d.bkt.clouddn.com/hls128.key 
HTTP/1.1 200 OK 
Server: Tengine
Content-Type: application/pgp-keys
Content-Length: 17 
``` 
但是钥匙串的长度不对正常的钥匙串是16,七牛的钥匙串长度为17，通过下钥匙串发现后面多一个"\n"导致的那么我们就要去除这个 "\n" 把它变成一个正产的链接,直接用AVPlayer播放系统也会报错，会返回钥匙串长度错误，下面我们就通过重定向来去除


#### (1) 重定向播放链接 AVAssetResourceLoader

通过AVURLAsset属性中有个resourceLoader,设置该属性的代理，当网络请求错误后，服务器会回调这个代理的重定向方法，我们可以手动让网络请求直接报错，这样我们就可以在AVURLAsset请求前拦截还做一些自定义操作例如对URI里的链接解密，或者把URI返回的Key做进一步操作

```
AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL: [[NSURL alloc] initWithString: @"m3u8Scheme://error.m3u8"] options: nil];
[[urlAsset resourceLoader] setDelegate: self queue: dispatch_get_main_queue()];
AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset: urlAsset];
[item setCanUseNetworkResourcesForLiveStreamingWhilePaused: YES]; 

``` 

可以看到因为我们填写的url 是个错误的url m3u8Scheme://error.m3u8 所以系统会回调错误
这个时候就可以收到代理回调 

```
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest;
```  
#### (2) 修改HLS 返回的M3u8文件中Key的链接,让这个链接也回调到上面的方法中
在回调中通过  NSString *url = [[[loadingRequest request] URL] absoluteString];
获取返回字符串 判断如果 @"m3u8Scheme://error.m3u8"就替换为我们记录好准备要请求的内容并将链接内key链接替换为一个错误的链接这样就能让这个链接也回调到上面的方法中

```
    if ([url isEqualToString: @"m3u8Scheme://error.m3u8"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [self M3u8Request: self->m3u8_url];
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
```  
#### (3) 修复Key中多余的"\n" 

``` 
    if (![url hasSuffix: @".ts"] && ![url isEqualToString: @"m3u8Scheme://error.m3u8"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   NSData *data = [self KeyRequest:url];
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
        if ([[NSFileManager defaultManager] fileExistsAtPath: fullPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        }
    
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
``` 
 
#### (4) 替换剩余.ts的请求头 
因为最开始我们替换了M3u8的请求链接导致后续的所有ts获取文件时系统会以这个这个头作为请求地址所以我们需要在把这里替换回来 

``` 
if ([url hasSuffix: @".ts"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * requestUrl =  [NSURL URLWithString:@"初始链接"];
            NSString *newUrl = [NSString stringWithFormat:@"http://%@",[url stringByReplacingOccurrencesOfString: @"m3u8Scheme://error.m3u8" withString: requestUrl.host]] ;
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
```  
到这一步时我们就完成的所有的重定向。 
# 如果Demo能对您有帮助请帮忙点个星 我将感激不尽 


 







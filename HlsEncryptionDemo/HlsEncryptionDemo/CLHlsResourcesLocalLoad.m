//
//  CLHlsResourcesLocalLoad.m
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import "CLHlsResourcesLocalLoad.h"

@interface CLHlsResourcesLocalLoad ()
@property (nonatomic, strong) NSString * path;
@end


@implementation CLHlsResourcesLocalLoad
+ (CLHlsResourcesLocalLoad *)shared {
    static CLHlsResourcesLocalLoad *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone: nil] init];
    });
    return instance;
}
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSString *url = [[[loadingRequest request] URL] absoluteString];
    NSLog(@"%@",loadingRequest.request.URL);
    //因为下载的时候已经系统存储的key的链接是个错误的以ckey开头的链接，所以还是会走到这个回调里这里在替换一次 AES-128的key 就可以正常播放本地HLS了
    if (![url hasSuffix: @".ts"] && ![url isEqualToString: @"m3u8Scheme://error.m3u8"]) {
          NSData * date = [[NSUserDefaults standardUserDefaults] objectForKey:@"localKey"];
          [[loadingRequest dataRequest] respondWithData:date ];
          [loadingRequest finishLoading];
          return true;
    }
    return true;
}
- (AVPlayerItem *)playItemWithLocalPath:(NSString *)path  {
    self.path = path;
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL: [NSURL fileURLWithPath:path]  options: nil];
    [[urlAsset resourceLoader] setDelegate: self queue: dispatch_get_main_queue()];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset: urlAsset];

    return item;
}

@end

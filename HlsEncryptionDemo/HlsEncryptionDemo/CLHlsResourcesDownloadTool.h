//
//  CLHlsResourcesDownloadTool.h
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface CLHlsResourcesDownloadTool : NSObject<AVAssetDownloadDelegate>

+ (instancetype)defaultManager ;

@property (nonatomic, strong) AVAssetDownloadTask * downLoadTask;
@property (nonatomic, strong) AVAssetDownloadURLSession * downLoadSession;

- (void)dowloadHlsAsset:(AVURLAsset *)asset progressBlock:(void(^)(float progress))progressBlock completeBlock:(void(^)(BOOL successd,NSString *path,NSError *error))completeBlock;




@end



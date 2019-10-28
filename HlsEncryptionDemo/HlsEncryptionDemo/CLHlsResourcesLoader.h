//
//  CLHlsResourcesLoader.h
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetResourceLoader.h>
#import <AVKit/AVKit.h>

@interface CLHlsResourcesLoader : NSObject<AVAssetResourceLoaderDelegate>
+ (CLHlsResourcesLoader *)shared;
- (AVPlayerItem *)playItemWith: (NSString *)url;
- (AVURLAsset *)downLoadAssetWith:(NSString *)url;

@end



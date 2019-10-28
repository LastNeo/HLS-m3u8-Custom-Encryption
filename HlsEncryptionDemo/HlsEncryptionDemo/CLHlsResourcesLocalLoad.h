//
//  CLHlsResourcesLocalLoad.h
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetResourceLoader.h>
#import <AVKit/AVKit.h>


@interface CLHlsResourcesLocalLoad : NSObject<AVAssetResourceLoaderDelegate>
+ (CLHlsResourcesLocalLoad *)shared;

- (AVPlayerItem *)playItemWithLocalPath:(NSString *)path ;

@end



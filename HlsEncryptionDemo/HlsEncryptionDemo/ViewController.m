//
//  ViewController.m
//  HlsEncryptionDemo
//
//  Created by ChaiLu on 2019/10/28.
//  Copyright © 2019 ChaiLu. All rights reserved.
//

#import "ViewController.h"
#import "CLHlsResourcesLoader.h"
#import "CLHlsResourcesLocalLoad.h"
#import "CLHlsResourcesDownloadTool.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *palyButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *playDownloadButton;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (IBAction)playButtonAction:(id)sender {
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.playerLayer removeFromSuperlayer];
    }
   AVPlayerItem  * item =  [[CLHlsResourcesLoader shared] playItemWith:@"http://ogn0m4it0.bkt.clouddn.com/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R"];
   self.player = [AVPlayer playerWithPlayerItem:item];
   [self.player  addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self createPlayLayer];
}



- (IBAction)downloadButtonAction:(id)sender {
     AVURLAsset  * asset =  [[CLHlsResourcesLoader shared] downLoadAssetWith:@"http://ogn0m4it0.bkt.clouddn.com/58IzAY_GglrObBBbbD98wrHIbLk=/llhpmYRGVWfZL8dyCPXwCwKovI9R"];
    [[CLHlsResourcesDownloadTool defaultManager] dowloadHlsAsset:asset progressBlock:^(float progress) {
        
    } completeBlock:^(BOOL successd, NSString *path, NSError *error) {
        if (successd) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"assetPath"];
            });
        }
    }];
}



- (IBAction)playDownloadButtonAction:(id)sender {
    NSString * path = [[NSUserDefaults standardUserDefaults] objectForKey:@"assetPath"];
    if (path) {
        if (self.player) {
            [self.player removeObserver:self forKeyPath:@"status"];
            [self.playerLayer removeFromSuperlayer];
        }
        NSString *homePath = NSHomeDirectory();
        NSString * filePath = [homePath stringByAppendingFormat:@"/%@",path];
        AVPlayerItem  * item =  [[CLHlsResourcesLocalLoad shared] playItemWithLocalPath:filePath];
        self.player = [AVPlayer playerWithPlayerItem:item];
        [self. player  addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [self createPlayLayer];
    }else {
        NSLog(@"请先点击下载");
    }
}


- (void)createPlayLayer {
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.contentsScale = [UIScreen mainScreen].scale;
    self.playerLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.playerLayer atIndex:0];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"status"]) {
             switch (self.player.status) {
                 case AVPlayerStatusUnknown:{
                     NSLog(@"KVO：未知状态，此时不能播放");
                     break;
                 }
                 case AVPlayerStatusReadyToPlay:{
                      NSLog(@"KVO：准备完毕，可以播放");
                     [self.player play];
                       break;
                 }
                 case AVPlayerStatusFailed:{
                     AVPlayerItem * item = (AVPlayerItem *)object;
                     NSLog(@"加载异常 %@",item.error);
               break;
                 }
              default:
               break;
             }
            }
    });
    
}
@end

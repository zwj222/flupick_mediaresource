//
//  PTXPlayMovieView.m
//  自定义照相机
//
//  Created by pantianxiang on 17/2/6.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "PTXPlayMovieView.h"
#import "PickMediasHeader.h"

@interface PTXPlayMovieView ()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation PTXPlayMovieView

static PTXPlayMovieView *_instance;
+ (PTXPlayMovieView *)sharePlayMovieView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[PTXPlayMovieView alloc] initWithFrame:CGRectZero];
        }
    });
    return _instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)setFileUrl:(NSURL *)fileUrl {
    _fileUrl = fileUrl;
    
    [self resetPlayer];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:fileUrl];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    self.playerLayer.frame = self.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)resetPlayer {
    if (_player) {
        [_player pause];
    }
    
    if (_playerLayer) {
        [_playerLayer removeFromSuperlayer];
    }
}

- (void)play {
    [_player play];
}

- (void)pause {
    [_player pause];
    
}

- (void)remos{
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//重复播放视频。
- (void)didFinishPlayMovie:(NSNotification *)notification {
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

#pragma mark 发送视频
//- (void)didSendPlayUrlButtonInview:(GZVedioTopView *)topView
//{
////    [self thumbnailImageForVideo:self.fileUrl atTime:60];
//}

// 获取图片第一帧
- (void)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
        
    self.hidden = YES;
    
    [self remos];

}

@end

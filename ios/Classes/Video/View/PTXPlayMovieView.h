//
//  PTXPlayMovieView.h
//  自定义照相机
//
//  Created by pantianxiang on 17/2/6.
//  Copyright © 2017年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PTXPlayMovieView : UIView

+ (PTXPlayMovieView *)sharePlayMovieView;

@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, strong) AVPlayer *player;

- (void)play;
- (void)pause;
- (void)remos;

@end

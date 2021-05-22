//
//  PTXTakePhotosView.m
//  自定义照相机
//
//  Created by pantianxiang on 17/2/4.
//  Copyright © 2017年 ys. All rights reserved.
//

#import "PTXTakePhotosView.h"
#import "ATCountdownButton.h"
#import "PickMediasHeader.h"

#define PTX_PROGRESS_WIDTH 4.0

@interface PTXTakePhotosView ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGR;
@property (nonatomic, strong) ATCountdownButton *videoBtn;

@end

@implementation PTXTakePhotosView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.videoBtn];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    self.videoBtn.frame = CGRectMake(0, 0, self.width, self.height);
}

- (void)tap:(UILongPressGestureRecognizer *)sender{
    __weak typeof(self)weakSelf =self;

    if (sender.state == UIGestureRecognizerStateBegan) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(beganRecordingVieoInView:)]) {
            [weakSelf.delegate beganRecordingVieoInView:weakSelf];
        }
        
        [self.videoBtn startWithDuration:PTX_VIDEO_MAX_DURATION block:^(CGFloat time) {
            self.longTime = time;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(timDuration:)]) {
                [weakSelf.delegate timDuration:weakSelf];
            }
        } completion:^(BOOL finished) {
            if (finished) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(endRecordingVieoInView:)]) {
                    [weakSelf.delegate endRecordingVieoInView:weakSelf];
                }
            }
        }];
    }
    //这里还有cancel的情况要处理， 还有就是时间的间隔要大于某个值才算真的拍了视频？
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.videoBtn stop];
                
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(endRecordingVieoInView:)]) {
            [weakSelf.delegate endRecordingVieoInView:weakSelf];
        }
    }
}

- (void)clickPhoto{
    if (_delegate && [_delegate respondsToSelector:@selector(didTriggerTakePhotosInView:)]) {
        [_delegate didTriggerTakePhotosInView:self];
    }
}

#pragma mark - Setter
- (ATCountdownButton *)videoBtn{
    if (!_videoBtn) {
        _videoBtn = [[ATCountdownButton alloc] initWithFrame:self.frame];
        _videoBtn.layer.cornerRadius = self.frame.size.width / 2;
        _videoBtn.layer.masksToBounds = YES;
        _videoBtn.backgroundColor = [UIColor colorWithRed:70/255.0 green:136/255.0 blue:254/255.0 alpha:1.0];
        _videoBtn.progressWidth = 5.0f;
        [_videoBtn addTarget:self action:@selector(clickPhoto) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [_videoBtn addGestureRecognizer:longPressGR];
    }
    return _videoBtn;
}

@end

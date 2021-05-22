//
//  GZPhotoBrowseCell.m
//  CommunityDemo
//
//  Created by soco on 2021/5/6.
//

#import "GZPhotoBrowseCell.h"
#import "PTXPlayMovieView.h"

#import "WZoomImageView.h"

#import "PickMediasHeader.h"

@interface GZPhotoBrowseCell ()

//展示、并实现图片缩放
@property (nonatomic, strong) WZoomImageView *hotoZoomView;
//拍视频成功之后显示
@property (nonatomic, strong) UIView *playMovieView;

//视频的标识
@property (weak, nonatomic) IBOutlet UIImageView *videoImgV;

@end

@implementation GZPhotoBrowseCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    //加入缩放的view
    [self.contentView insertSubview:self.hotoZoomView atIndex:0];
    
    //播放视频的view
    [self.contentView insertSubview:self.playMovieView atIndex:0];
}

//如果在播放视频，则关闭视频，释放内存
- (void)freeVideoMemoryIfNeed{
    if (self.model.type == AliyunAssetModelMediaTypeVideo) {
        [[PTXPlayMovieView sharePlayMovieView] pause];
        [[PTXPlayMovieView sharePlayMovieView] remos];
    }
}

//如果是图片，则切换后要还原
- (void)resetScaleImageIfNeed{
    if (self.model.type != AliyunAssetModelMediaTypeVideo) {
        [self.hotoZoomView resetScale];
    }
}

- (void)setModel:(AliyunAssetModel *)model{
    _model = model;
    
    //先把界面清楚干净
    if ([PTXPlayMovieView sharePlayMovieView].superview) {
        [[PTXPlayMovieView sharePlayMovieView] removeFromSuperview];
        [[PTXPlayMovieView sharePlayMovieView] pause];
    }
    
    if (model.type == AliyunAssetModelMediaTypeVideo) {
        self.videoImgV.alpha = 1.0;
        self.videoImgV.hidden = NO;
        self.hotoZoomView.hidden = YES;
        self.playMovieView.hidden = NO;
        
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:model.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            //这里要主线程？
            dispatch_async(dispatch_get_main_queue(), ^{
                [PTXPlayMovieView sharePlayMovieView].frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                [self.playMovieView addSubview:[PTXPlayMovieView sharePlayMovieView]];
                
                //拿到avAsset  直接强转成AVURLAsset， 再拿它的url来播放
                AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                [PTXPlayMovieView sharePlayMovieView].fileUrl = urlAsset.URL;
                [[PTXPlayMovieView sharePlayMovieView] play];
                
                [UIView animateWithDuration:1.5 animations:^{
                    self.videoImgV.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.videoImgV.hidden = YES;
                }];
            });
        }];
    } else {
        self.videoImgV.hidden = YES;
        self.hotoZoomView.hidden = NO;
        [self.hotoZoomView resetScale];
        self.playMovieView.hidden = YES;
        
        [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:model.asset thumbnailImage:NO photoWidth:ScreenWidth completion:^(UIImage *photo, NSDictionary *info) {
            if(photo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hotoZoomView resetScale];
                    [self.hotoZoomView showImageWithPhotoImage:photo];
                });
            }
        }];
    }
}

- (WZoomImageView *)hotoZoomView{
    if (!_hotoZoomView) {
        _hotoZoomView = [[WZoomImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    }
    return _hotoZoomView;
}

- (UIView *)playMovieView{
    if (!_playMovieView) {
        _playMovieView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    };
    return _playMovieView;
}


@end

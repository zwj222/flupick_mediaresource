//
//  GZAlbumCell.m
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

//这两个变量在另一个页面申明的，这个文件里拿来使用就好
extern NSInteger _videoNumber;
extern NSInteger _albumNumber;

#import "GZAlbumCell.h"
#import "AliyunPhotoLibraryManager.h"

@interface GZAlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *albumImgV;
@property (weak, nonatomic) IBOutlet UILabel *durationLab;

@property (weak, nonatomic) IBOutlet UIImageView *selectImgV;

@end

@implementation GZAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.maskView.hidden = YES;
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)];
    [self.maskView addGestureRecognizer:tag];
}

//遮罩的点击事件，应该不要处理
- (void)touchAction{
    
}

- (void)setModel:(AliyunAssetModel *)model{
    _model = model;
    
    if (model.asset == nil) {
        //则是添加按钮
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"assets_take" ofType:@"png"];
        self.albumImgV.image = [UIImage imageWithContentsOfFile:imagePath];
        self.albumImgV.backgroundColor = [UIColor grayColor];
        self.albumImgV.contentMode = UIViewContentModeCenter;
        
        //选中的图标要去掉
        self.selectImgV.image = nil;
        //遮罩层去掉
        self.maskView.hidden = YES;
        //时间长度的文字去掉
        self.durationLab.text = @"";
        self.durationLab.hidden = YES;
    } else {
        self.albumImgV.backgroundColor = [UIColor whiteColor];
        self.albumImgV.contentMode = UIViewContentModeScaleAspectFill;
        
        //选中
        if (model.isSelected) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"assets_selected" ofType:@"png"];
            self.selectImgV.image = [UIImage imageWithContentsOfFile:imagePath];
        } else {
            self.selectImgV.image = nil;
        }
        
        if (model.type != AliyunAssetModelMediaTypeVideo) { //图片
            //如果选择了视频，则图片全置灰
            if (_videoNumber >= 1) {
                self.maskView.hidden = NO;
            } else {
                //默认只能选9张
                if (_albumNumber >= 9) {
                    if (model.isSelected) {
                        self.maskView.hidden = YES;
                    } else {
                        self.maskView.hidden = NO;
                    }
                } else {
                    self.maskView.hidden = YES;
                }
            }
        } else {//视频
            self.maskView.hidden = YES;

            if (_albumNumber > 0) {
                self.maskView.hidden = NO;
            } else {
                self.maskView.hidden = YES;
            }
        }
        
        self.durationLab.text = model.timeLength;
        self.durationLab.hidden = model.type == 0;
        self.albumImgV.image = nil;
        if (model.fetchThumbnail) {
            self.albumImgV.image = model.thumbnailImage;
        } else {
            [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:model.asset thumbnailImage:NO photoWidth:80 completion:^(UIImage *photo, NSDictionary *info) {
                if(photo) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        model.fetchThumbnail = YES;
                        model.thumbnailImage = photo;
                        self.albumImgV.image = photo;
                    });
                }
            }];
        }
    }
}

- (IBAction)selectBtnClick:(id)sender {
    if (self.selectPhotoBlock) {
        self.selectPhotoBlock();
    }
}


@end

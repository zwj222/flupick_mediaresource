//
//  WZoomImageView.h
//  ObtainResource
//
//  Created by Willian on 2021/5/7.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ShowImageState) {
    ShowImageStateSmall,    // 初始化默认是小图
    ShowImageStateBig,   // 全屏的正常图片
    ShowImageStateOrigin    // 原图
};

@interface WZoomImageView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, assign, readonly) ShowImageState imageState;

- (void)resetScale;
- (void)showImageWithPhotoImage:(UIImage *)image;

@end


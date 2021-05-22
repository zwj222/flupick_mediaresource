//
//  GZVideoCompletVC.h
//  CommunityDemo
//
//  Created by soco on 2021/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GZVideoCompletVC : UIViewController

//是否是拍照
@property (nonatomic, assign) BOOL isPhoto;

//拍照图片
@property (nonatomic, strong) UIImage *photoImg;

//视频链接
@property (nonatomic, copy) NSURL *recodingUrl;

// 返回是开始摄像头
@property (nonatomic, copy) void (^popBlock)(void);

@end

NS_ASSUME_NONNULL_END

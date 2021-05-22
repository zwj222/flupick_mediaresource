//
//  GZSelectAlbumVC.h
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickMediasHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GZSelectAlbumVC : UIViewController

//最大张数
//只能视频
//只能图片
//展示每一行显示几个
//

//最后确定使用选择好的资源了
@property (nonatomic, copy) void (^selectedAndConfirmUseResourceBlock)(NSArray<AliyunAssetModel *>* resArr);


@end

NS_ASSUME_NONNULL_END

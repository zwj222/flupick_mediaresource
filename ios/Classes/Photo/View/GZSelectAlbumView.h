//
//  GZSelectAlbumView.h
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GZSelectAlbumVC.h"
#import "PickMediasHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GZSelectAlbumView : UIView

@property (nonatomic,copy) void(^popBlock)(void);
@property (nonatomic, copy) void (^takingPhotoBlock)(UIButton *sender);

//最后确定使用选择好的资源了
@property (nonatomic, copy) void (^selectedAndConfirmUseBlock)(NSArray<AliyunAssetModel *>* resArr);

+ (instancetype)createGZSelectAlbumView;

@end

NS_ASSUME_NONNULL_END

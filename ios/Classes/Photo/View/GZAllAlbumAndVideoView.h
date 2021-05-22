//
//  GZAllAlbumAndVideoView.h
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPhotoLibraryManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GZAllAlbumAndVideoView : UIView

+ (instancetype)createGZAllAlbumAndVideoView;

//0：全部，1：视频，2：照片
@property (nonatomic,assign) NSInteger type;
//总数据存储
@property (nonatomic,strong) NSArray<AliyunAssetModel*> *totalSaveArray;

@end

NS_ASSUME_NONNULL_END

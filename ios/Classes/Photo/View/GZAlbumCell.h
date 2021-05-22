//
//  GZAlbumCell.h
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GZAlbumCell : UICollectionViewCell

@property (nonatomic,copy) void(^selectPhotoBlock)(void);

@property (nonatomic,strong) AliyunAssetModel *model;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@end

NS_ASSUME_NONNULL_END

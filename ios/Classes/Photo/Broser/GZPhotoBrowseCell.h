//
//  GZPhotoBrowseCell.h
//  CommunityDemo
//
//  Created by soco on 2021/5/6.
//

#import <UIKit/UIKit.h>
#import "AliyunAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GZPhotoBrowseCell : UICollectionViewCell

@property (nonatomic, strong) AliyunAssetModel *model;

//如果在播放视频，则关闭视频，释放内存
- (void)freeVideoMemoryIfNeed;
//如果是图片，则切换后要还原
- (void)resetScaleImageIfNeed;

@end

NS_ASSUME_NONNULL_END

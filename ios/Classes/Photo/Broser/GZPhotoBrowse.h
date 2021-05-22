//
//  GZPhotoBrowse.h
//  CommunityDemo
//
//  Created by soco on 2021/5/6.
//

#import <UIKit/UIKit.h>
#import "PickMediasHeader.h"

typedef void(^AssetItemSelectStatusChangeBlock)(NSInteger selectIndex);
typedef BOOL(^AssetItemIsCanSelectBlock)(NSInteger selectIndex);
typedef void(^ConfirmUseResourceBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface GZPhotoBrowse : UIViewController

//开始的时候，跳转到默认的那个页码去
@property (nonatomic, assign) NSInteger selectIndex;
//总数据源
@property (nonatomic, strong) NSArray<AliyunAssetModel*> *totalArray;
//是不是预览
@property (nonatomic, assign) BOOL isBrower;

//改变数据的是否选中的回调
@property (nonatomic, copy) AssetItemSelectStatusChangeBlock assetItemSelectStatusChangeBlock;

//如果已经选图片了，就不能选视频了，而且图片最多不能超过9张
//如果选视频了，就不能选图片了，而且视频最多只能选一个
//由它的上一级来处理
@property (nonatomic, copy) AssetItemIsCanSelectBlock assetItemIsCanSelectBlock;




//最后真的确定使用的回调
@property (nonatomic, copy) ConfirmUseResourceBlock confirmUseResourceBlock;

@end

NS_ASSUME_NONNULL_END

//
//  GZSelectVideoVC.h
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AliyunAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TakeResourceResBlock)(AliyunAssetModel *assetModel);

@interface GZSelectVideoVC : UIViewController

//从哪里来的，比如是从相册来的，还是直接从外面过来的
@property (nonatomic, assign) NSString *fromWhat;

//是不是只能拍照片
@property (nonatomic, assign) BOOL isOnlyAllowTakePhoto;

//当前相册的信息
@property (nonatomic, strong) AliyunAlbumModel *albemModel;

//结果回调
@property (nonatomic, copy) TakeResourceResBlock takeResourceResBlock;

- (instancetype)initWithFromWhat:(NSString *)fromWhat isOnlyAllowTakePhoto:(BOOL)isOnlyAllowTakePhoto albemModel:(AliyunAlbumModel *)albemModel takeResourceResBlock:(TakeResourceResBlock)takeResourceResBlock;

@end

NS_ASSUME_NONNULL_END

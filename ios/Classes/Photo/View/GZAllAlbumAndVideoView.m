//
//  GZAllAlbumAndVideoView.m
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

//视频个数：1
NSInteger _videoNumber;
//图片个数：最多9张
NSInteger _albumNumber;

#import "GZAllAlbumAndVideoView.h"
#import "GZAlbumCell.h"
#import "GZPhotoBrowse.h"

#import "GZSelectVideoVC.h"
#import "PickMediasHeader.h"

@interface GZAllAlbumAndVideoView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//数据源
@property (nonatomic, strong) NSMutableArray<AliyunAssetModel*> *totalArray;
@property (nonatomic, strong) NSMutableArray<AliyunAssetModel*> *albumArray;
@property (nonatomic, strong) NSMutableArray<AliyunAssetModel*> *videoArray;

//当前的albem
@property (nonatomic, strong) AliyunAlbumModel *currentAlbemModel;
//拍照回来的东西
@property (nonatomic, strong) AliyunAssetModel *currentAssetModel;

@end

@implementation GZAllAlbumAndVideoView

+ (instancetype)createGZAllAlbumAndVideoView{
    return [[NSBundle mainBundle] loadNibNamed:@"GZAllAlbumAndVideoView" owner:self options:nil][0];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _videoNumber = 0;
    _albumNumber = 0;

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"GZAlbumCell" bundle:nil] forCellWithReuseIdentifier:@"GZAlbumCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAlbumAndVideo:) name:@"reloadAlbumAndVideo" object:nil];
    
    //获取某个相册分类下的所有数据
    [self getAllAlbumAndVideoImages];
}

//切换相册类型
- (void)setType:(NSInteger)type{
    _type = type;
    
    [self.collectionView reloadData];
}

#pragma mark - 相册列表选取，更新数据源
- (void)reloadAlbumAndVideo:(NSNotification *)obj{
    [self reloadLibrarydWithAlbumModel:obj.object];
}

- (void)reloadLibrarydWithAlbumModel:(AliyunAlbumModel *)model{

    //当前的相册集变了
    self.currentAlbemModel = model;
    
    __weak typeof(self)weakSelf = self;
    [[AliyunPhotoLibraryManager sharedManager] getAssetsFromFetchResult:model.fetchResult allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<AliyunAssetModel *> *models) {
        
        [weakSelf.totalArray removeAllObjects];
        [weakSelf.videoArray removeAllObjects];
        [weakSelf.albumArray removeAllObjects];
        
        NSMutableArray *videoArr = [NSMutableArray array];
        NSMutableArray *albumArr = [NSMutableArray array];

        for (AliyunAssetModel *model in models) {
            if (model.type == AliyunAssetModelMediaTypeVideo) {
                [videoArr addObject:model];
            } else {
                [albumArr addObject:model];
            }
        }
        
        //把选中的筛选出来？
        for (AliyunAssetModel *model1 in weakSelf.totalSaveArray) {
            for (AliyunAssetModel *model2 in models) {
                if ([model2.asset isEqual:model1.asset]) {
                    if (model1.isSelected) {
                        model2.isSelected = model1.isSelected;
                    }
                }
            }
        }
        
        //先把结果保存起来
        [weakSelf.totalArray addObjectsFromArray: models];
        //这里的最前面要添加一个拍照的按钮
//        AliyunAssetModel *takePhotoModel = [AliyunAssetModel new];
//        [weakSelf.totalArray insertObject:takePhotoModel atIndex:0];
        
        [weakSelf.videoArray addObjectsFromArray: videoArr];
        [weakSelf.albumArray addObjectsFromArray: albumArr];

        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - 获取所有的视频和照片
- (void)getAllAlbumAndVideoImages{
    __weak typeof(self)weakSelf = self;
    [[AliyunPhotoLibraryManager sharedManager] requestAuthorization:^(BOOL authorization) {
        if (authorization) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //视频时间限制，min最小，max最大，单位s
                VideoDurationRange duration = {0.0, 0.0};

                [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:YES allowPickingImage:YES durationRange:duration completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount, AliyunAlbumModel *albemModel) {//!videoOnly
                    
                    //保存第一次显示的相册集
                    weakSelf.currentAlbemModel = albemModel;
                    
                    [weakSelf.totalArray removeAllObjects];
                    [weakSelf.videoArray removeAllObjects];
                    [weakSelf.albumArray removeAllObjects];
                    
                    //先把结果保存起来
                    weakSelf.totalSaveArray = models;
                    

                    NSMutableArray *videoArr = [NSMutableArray array];
                    NSMutableArray *albumArr = [NSMutableArray array];

                    for (AliyunAssetModel *model in models) {
                        if (model.type == AliyunAssetModelMediaTypeVideo) {
                            [videoArr addObject:model];
                        }else{
                            [albumArr addObject:model];
                        }
                    }
                    
                    [weakSelf.totalArray addObjectsFromArray: models];
                    //这里的最前面要添加一个拍照的按钮
//                    AliyunAssetModel *takePhotoModel = [AliyunAssetModel new];
//                    [weakSelf.totalArray insertObject:takePhotoModel atIndex:0];
                    
                    [weakSelf.videoArray addObjectsFromArray: videoArr];
                    [weakSelf.albumArray addObjectsFromArray: albumArr];

                    [weakSelf.collectionView reloadData];
                }];
            });
        }
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (self.type) {
        case 0:{
            return self.totalArray.count;
            break;
        }
        case 1:{
            return self.videoArray.count;
            break;
        }
        case 2:{
            return self.albumArray.count;
            break;
        }
    }
    return self.totalArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GZAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GZAlbumCell" forIndexPath:indexPath];
    switch (self.type) {
        case 0:{
            cell.model = self.totalArray[indexPath.item];
            break;
        }
        case 1:{
            cell.model = self.videoArray[indexPath.item];
            break;
        }
        case 2:{
            cell.model = self.albumArray[indexPath.item];
            break;
        }
    }
    //某个cell选中的操作
    cell.selectPhotoBlock = ^{
        [self taggerSelectStatusWithIndexPath:indexPath];
    };
    
    return cell;
}

//某个资源的选中状态切换
- (void)taggerSelectStatusWithIndexPath:(NSIndexPath *)indexPath{
    //逻辑稍微复杂
    switch (self.type) {
        case 0:{
            AliyunAssetModel *model = self.totalArray[indexPath.item];
            if (model.asset.pixelWidth + model.asset.pixelHeight <= 0) {//防止一些text等非媒体文件手动改成png等媒体文件格式传进来
                [MBProgressHUD showMessage:@"文件已损坏" inView:self];
                return;
            }
            
            if (model.type == AliyunAssetModelMediaTypeVideo) {
                //如果选中，不进行下面操作
                if (model.isSelected) {
                    model.isSelected = !model.isSelected;
                    _videoNumber = 0;
                    [self.collectionView reloadData];
                    return;
                }
                
                for (AliyunAssetModel *allModel in self.videoArray) {
                    allModel.isSelected = NO;
                }
                for (AliyunAssetModel *videoModel in self.totalSaveArray) {
                    if (videoModel.type == AliyunAssetModelMediaTypeVideo) {
                        videoModel.isSelected = NO;
                    }
                }
                model.isSelected = !model.isSelected;
                _videoNumber = 1;
            } else {
                model.isSelected = !model.isSelected;
                
                NSInteger i = 0;
                for (AliyunAssetModel *albumModel in self.totalSaveArray) {
                    if ([albumModel.asset isEqual:model.asset]) {
                        albumModel.isSelected = model.isSelected;
                    }
                    if (albumModel.isSelected) {
                        i++;
                    }
                }
                
                _albumNumber = i;
            }
            break;
        }
        case 1:{
            AliyunAssetModel *model = self.videoArray[indexPath.item];
            if (model.asset.pixelWidth + model.asset.pixelHeight <= 0) {//防止一些text等非媒体文件手动改成png等媒体文件格式传进来
                [MBProgressHUD showMessage:@"文件已损坏" inView:self];
                return;
            }
            //如果选中，不进行下面操作
            if (model.isSelected) {
                model.isSelected = !model.isSelected;
                _videoNumber = 0;
                [self.collectionView reloadData];
                return;
            }
            for (AliyunAssetModel *allModel in self.videoArray) {
                allModel.isSelected = NO;
            }
            for (AliyunAssetModel *videoModel in self.totalSaveArray) {
                if (videoModel.type == AliyunAssetModelMediaTypeVideo) {
                    videoModel.isSelected = NO;
                }
            }
            model.isSelected = !model.isSelected;
            _videoNumber = 1;
            
            break;
        }
        case 2: {
            AliyunAssetModel *model = self.albumArray[indexPath.item];
            if (model.asset.pixelWidth + model.asset.pixelHeight <= 0) {//防止一些text等非媒体文件手动改成png等媒体文件格式传进来
                [MBProgressHUD showMessage:@"文件已损坏" inView:self];
                return;
            }
            
            model.isSelected = !model.isSelected;
            
            NSInteger i = 0;
            for (AliyunAssetModel *albumModel in self.totalSaveArray) {
                if ([albumModel.asset isEqual:model.asset]) {
                    albumModel.isSelected = model.isSelected;
                }
                if (albumModel.isSelected) {
                    i ++;
                }
            }
            _albumNumber = i;
            
            break;
        }
    }
    [self.collectionView reloadData];
}


/*
 if (model.asset == nil) {
     //这里直接去拍照
     GZSelectVideoVC *vc = [[GZSelectVideoVC alloc] initWithFromWhat:@"albem" isOnlyAllowTakePhoto:YES albemModel:self.currentAlbemModel takeResourceResBlock:^(AliyunAssetModel * _Nonnull assetModel) {
         //结果回调处理
         self.currentAssetModel = assetModel;
     
         //重新刷数据  获取异步的主线程
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 //2.0秒后追加任务代码到主队列，并开始执行
             //发送通知，将albumModel带过去
             [self reloadLibrarydWithAlbumModel:self.currentAlbemModel];
         });
     }];
     //这里应该要返回结果，然后把它当做选中状态
     [[self viewController].navigationController pushViewController:vc animated:YES];
     return;
 }
 
 */

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    //这里做全部预览功能
    GZPhotoBrowse *vc = [GZPhotoBrowse new];
    vc.assetItemSelectStatusChangeBlock = ^(NSInteger selectIndex) {
        [self taggerSelectStatusWithIndexPath:[NSIndexPath indexPathForItem:selectIndex inSection:0]];
    };
    
    vc.assetItemIsCanSelectBlock = ^BOOL(NSInteger selectIndex) {
        //要拿到当前的模型
        AliyunAssetModel *model = self.totalArray[selectIndex];
        
        //如果原来这个资源是选中状态的，则取消选中 返回yes
        if (model.isSelected) {
            return YES;
        }
        //如果选视频了，就不能选图片了，而且视频最多只能选一个
        if(_videoNumber == 1){
            return NO;
        }else {
            //这里是什么都还没选
            if (_albumNumber == 0) {
                return YES;
            } else {  //这是已经选图片
                if(model.type == AliyunAssetModelMediaTypeVideo){
                    return NO;
                }else{
                    //如果已经选图片了，就不能选视频了，而且图片最多不能超过9张
                    if (_albumNumber >= 9) {
                        return NO;
                    }else{
                        return YES;
                    }
                }
            }
        }
        //最后
        return NO;
    };
    //冲刷界面的回调
    vc.isBrower = YES;
    vc.selectIndex = indexPath.row;
    vc.totalArray = self.totalSaveArray;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ScreenWidth / 4.0, ScreenWidth / 4.0);
}

- (NSMutableArray<AliyunAssetModel *> *)totalArray{
    if (!_totalArray) {
        _totalArray = [NSMutableArray array];
    }
    return _totalArray;
}

- (NSMutableArray<AliyunAssetModel *> *)videoArray{
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

- (NSMutableArray<AliyunAssetModel *> *)albumArray{
    if (!_albumArray) {
        _albumArray = [NSMutableArray array];
    }
    return _albumArray;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadAlbumAndVideo" object:nil];
}

@end

//
//  GZPhotoBrowse.m
//  CommunityDemo
//
//  Created by soco on 2021/5/6.
//

#import "GZPhotoBrowse.h"
#import "GZPhotoBrowseCell.h"

@interface GZPhotoBrowse ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UIView *topBGV;
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) UILabel *curCountlab;

@property (strong, nonatomic) UIButton *selectBtn;
@property (strong, nonatomic) UIButton *configUseBtn;

@end

@implementation GZPhotoBrowse

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.topBGV];
    
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.curCountlab];
    [self.view addSubview:self.configUseBtn];
    [self.view addSubview:self.selectBtn];
    
    for (AliyunAssetModel *model in self.totalArray) {
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:model.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                model.videoURL = urlAsset.URL;
            });
        }];
    }
    
    [self.collectionView reloadData];
}

- (void)setConfirmUseResourceBlock:(ConfirmUseResourceBlock)confirmUseResourceBlock{
    _confirmUseResourceBlock = confirmUseResourceBlock;
}

- (void)setAssetItemSelectStatusChangeBlock:(AssetItemSelectStatusChangeBlock)assetItemSelectStatusChangeBlock{
    _assetItemSelectStatusChangeBlock = assetItemSelectStatusChangeBlock;
}

- (void)setAssetItemIsCanSelectBlock:(AssetItemIsCanSelectBlock)assetItemIsCanSelectBlock{
    _assetItemIsCanSelectBlock = assetItemIsCanSelectBlock;
}

- (void)setIsBrower:(BOOL)isBrower{
    _isBrower = isBrower;
    if (isBrower) {
        self.configUseBtn.hidden = YES;
        self.selectBtn.hidden = NO;
    }else{
        self.selectBtn.hidden = YES;
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    
    self.curCountlab.text = [NSString stringWithFormat:@"%ld/%lu", (selectIndex + 1), (unsigned long)self.totalArray.count];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat offsetX = self.selectIndex * ScreenWidth;
        [self.collectionView setContentOffset:CGPointMake(offsetX, 0)];
        [self.collectionView reloadData];
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.totalArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    //显示之前把图片缩放玻璃还原还要
    [(GZPhotoBrowseCell *)cell resetScaleImageIfNeed];
    
    //切换上面当前显示的第几张
    _curCountlab.text = [NSString stringWithFormat:@"%ld/%ld", (indexPath.item + 1), self.totalArray.count];
    
    AliyunAssetModel *model = self.totalArray[indexPath.item];
    ((GZPhotoBrowseCell *)cell).model = model;
    //设置当前页面选择按钮的状态
    [self setSelectBtnStatusWithAssetModel:model];
}

- (void)setSelectBtnStatusWithAssetModel:(AliyunAssetModel *)assetModel{
    NSString *imagePath;
    if (assetModel.isSelected) {
        imagePath = [[NSBundle mainBundle] pathForResource:@"assets_selected" ofType:@"png"];
    } else {
        imagePath = [[NSBundle mainBundle] pathForResource:@"assets_un_selected" ofType:@"png"];
    }
    [_selectBtn setImage:[UIImage imageCompressForSize:[UIImage imageWithContentsOfFile:imagePath] targetSize:CGSizeMake(18, 18)] forState:UIControlStateNormal];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GZPhotoBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GZPhotoBrowseCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //这里应该不要做什么的
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ScreenWidth, ScreenHeight);
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(ScreenWidth, ScreenHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_collectionView registerNib:[UINib nibWithNibName:@"GZPhotoBrowseCell" bundle:nil] forCellWithReuseIdentifier:@"GZPhotoBrowseCell"];
    }
    return _collectionView;
}

- (UIView *)topBGV{
    if (!_topBGV) {
        _topBGV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 108)];
        _topBGV.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    }
    return _topBGV;
}

- (UILabel *)curCountlab{
    if (!_curCountlab) {
        _curCountlab = [[UILabel alloc] init];
        _curCountlab.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _curCountlab.layer.cornerRadius = 18;
        _curCountlab.layer.masksToBounds = YES;
        _curCountlab.frame = CGRectMake((ScreenWidth - 98)/2.0, STATUSHEIGHT, 98, 36);
        _curCountlab.textColor = [UIColor whiteColor];
        _curCountlab.font = [UIFont boldSystemFontOfSize:20];
        _curCountlab.textAlignment = NSTextAlignmentCenter;
    }
    return _curCountlab;
}

//关闭按钮回调
- (void)closeBtnClick{
    //过如果在播视频，则要停止播放，释放内存
    GZPhotoBrowseCell *cell = (GZPhotoBrowseCell *)([self.collectionView visibleCells].firstObject);
    [cell freeVideoMemoryIfNeed];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _closeBtn.frame = CGRectMake(14, STATUSHEIGHT, 36, 36);
        _closeBtn.layer.cornerRadius = 18;
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"assets_close_white" ofType:@"png"];
        [_closeBtn setImage:[UIImage imageCompressForSize:[UIImage imageWithContentsOfFile:imagePath] targetSize:CGSizeMake(18, 18)] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)configUseBtnClick{
    NSLog(@"使用照片");
    //怎么暴露到外面去呢？
    if (self.confirmUseResourceBlock) {
        self.confirmUseResourceBlock();
    }
}

- (UIButton *)configUseBtn{
    if (!_configUseBtn) {
        _configUseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _configUseBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [_configUseBtn setTitle:@"使用" forState:UIControlStateNormal];
        [_configUseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _configUseBtn.frame = CGRectMake(ScreenWidth - (14 + 74), STATUSHEIGHT, 74, 36);
        _configUseBtn.layer.cornerRadius = 18;
        [_configUseBtn addTarget:self action:@selector(configUseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _configUseBtn;
}

//拿到当前的index,改变数据，
- (void)selectBtnClick{
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    //先问上一个页面，是不是还能操作？
    if (self.assetItemIsCanSelectBlock) {
        BOOL isCanChange = self.assetItemIsCanSelectBlock(indexPath.item);
        
        if (isCanChange) {
            //先刷新上一个页面，刷界面
            if (self.assetItemSelectStatusChangeBlock) {
                self.assetItemSelectStatusChangeBlock(indexPath.item);
            }
            
            //这个页面的数据状态已经跟上个页面同步了
            AliyunAssetModel *model = self.totalArray[indexPath.item];
            //先把当前界面的按钮状态改变了   设置当前页面选择按钮的状态
            [self setSelectBtnStatusWithAssetModel:model];
        }else{
            //这里要给个提示
            [MBProgressHUD showMessage:@"不能再多选了！" inView:self.view];
        }
    }
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _selectBtn.frame = CGRectMake(ScreenWidth - (14 + 36), STATUSHEIGHT, 36, 36);
        _selectBtn.layer.cornerRadius = 18;
        [_selectBtn addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}


@end

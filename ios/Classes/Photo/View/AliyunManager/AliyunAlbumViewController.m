//
//  AliyunAlbumViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/12.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunAlbumViewController.h"
#import "AliyunAlbumTableViewCell.h"
#import "PickMediasHeader.h"

@interface AliyunAlbumViewController ()
@property (nonatomic, strong)  UIButton *buttonCancel;
@property (nonatomic, strong)  UIButton *buttonTitle;
@property (nonatomic, strong)  UITableView *tableView;

@property (nonatomic, strong) NSArray *albumDataArray;
@end

@implementation AliyunAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    [self setupSubViews];
    VideoDurationRange duration = _videoRange;
    
    __weak typeof(self) weakSelf = self;
    [[AliyunPhotoLibraryManager sharedManager] getAllAlbums:YES allowPickingImage:!self.videoOnly durationRange:duration completion:^(NSArray<AliyunAlbumModel *> *models) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.albumDataArray = models;
        [strongSelf.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.tableView.frame = CGRectMake(0, 44+ STATUSHEIGHT, ScreenWidth, ScreenHeight - 44 -STATUSHEIGHT);
    }];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setupSubViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight-44-STATUSHEIGHT-SafeAreaTopHeight) style:UITableViewStylePlain];
    _tableView.dataSource = (id<UITableViewDataSource>)self;
    _tableView.delegate = (id<UITableViewDelegate>)self;
    [_tableView registerClass:[AliyunAlbumTableViewCell class] forCellReuseIdentifier:@"AliyunAlbumTableViewCell"];
    _tableView.rowHeight = 64;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.alwaysBounceVertical = YES;
    [self.view addSubview:_tableView];
    
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44+ STATUSHEIGHT)];
    navigationView.backgroundColor = [UIColor clearColor];
    [navigationView addSubview:self.buttonTitle];
    [navigationView addSubview:self.buttonCancel];
    [self.view addSubview:navigationView];
    [self updateNavigationTitle:_albumTitle];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AliyunAlbumTableViewCell"];

    AliyunAlbumModel *model = _albumDataArray[indexPath.row];
    cell.albumModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AliyunAlbumModel *model = _albumDataArray[indexPath.row];
    _selectBlock(model);
    [self viewDisAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buttonTitleClick:(id)sender {
    [self viewDisAnimation];
}

- (void)buttonCancelClick:(id)sender {
    [self viewDisAnimation];
}

- (void)viewDisAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 64);
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)updateNavigationTitle:(NSString *)title {
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(180, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_buttonTitle.titleLabel.font} context:nil].size;
    [_buttonTitle setTitle:title forState:0];
    [_buttonTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, -12 - 4, 0, 12 + 4)];
    [_buttonTitle setImageEdgeInsets:UIEdgeInsetsMake(0, size.width + 4, 0, -size.width - 4)];
    [_buttonTitle.imageView setTransform:CGAffineTransformMakeRotation(M_PI)];
}

- (UIButton *)buttonTitle {
    if (!_buttonTitle) {
        _buttonTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonTitle.bounds = CGRectMake(0, 0, 180, 44);
        _buttonTitle.center = CGPointMake(ScreenWidth / 2, 22 + STATUSHEIGHT);
        [_buttonTitle setTitleColor:[UIColor whiteColor] forState:0];
        
        UIImage *downImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"assets_roll_list" ofType:@"png"]];
        [_buttonTitle setImage:[UIImage imageCompressForSize:downImage targetSize:CGSizeMake(12, 12)] forState:0];
        [_buttonTitle addTarget:self action:@selector(buttonTitleClick:) forControlEvents:UIControlEventTouchUpInside];
        _buttonTitle.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _buttonTitle;
}

// 支持设备自动旋转
- (BOOL)shouldAutorotate{
    return YES;
}

// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIButton *)buttonCancel {
    if (!_buttonCancel) {
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonCancel.frame = CGRectMake(15, STATUSHEIGHT, 44, 44);
        [_buttonCancel setTitleColor:[UIColor whiteColor] forState:0];
        [_buttonCancel setTitle:NSLocalizedString(@"取消" , nil) forState:0];
        [_buttonCancel addTarget:self action:@selector(buttonCancelClick:) forControlEvents:UIControlEventTouchUpInside];
        _buttonCancel.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _buttonCancel;
}

@end

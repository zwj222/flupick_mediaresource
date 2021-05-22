//
//  GZSelectVideoVC.m
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import "GZSelectVideoVC.h"
#import "GZSelectVideoView.h"
#import "PickMediasHeader.h"

@interface GZSelectVideoVC ()

@property (nonatomic, strong) GZSelectVideoView *mainView;

@end

@implementation GZSelectVideoVC

- (instancetype)initWithFromWhat:(NSString *)fromWhat isOnlyAllowTakePhoto:(BOOL)isOnlyAllowTakePhoto albemModel:(AliyunAlbumModel *)albemModel takeResourceResBlock:(TakeResourceResBlock)takeResourceResBlock;{
    self = [super init];
    if (self) {
        self.fromWhat = fromWhat;
        self.isOnlyAllowTakePhoto = isOnlyAllowTakePhoto;
        self.albemModel = albemModel;
        self.takeResourceResBlock = takeResourceResBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mainView];
}

- (GZSelectVideoView *)mainView {
    if (!_mainView) {
        __weak typeof(self) weakSelf = self;
        _mainView = [GZSelectVideoView createGZSelectVideoView];
        _mainView.popBlock = ^{
            __strong typeof(self) strongSelf = weakSelf;
            if ([strongSelf.fromWhat isEqualToString:@"albem"]) {
                [strongSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [strongSelf.navigationController dismissViewControllerAnimated:YES completion:^{ }];
            }
        };
        _mainView.takePicBlock = ^(UIImage * _Nonnull image) {
            __strong typeof(self) strongSelf = weakSelf;
            [[AliyunPhotoLibraryManager sharedManager] saveImage:image toAlbem:strongSelf.albemModel completion:^(NSError * error, AliyunAssetModel *resAssetModel) {
                if (error) {
                    //保存失败
                }else{
                    //保存成功 怎么回调？
                    if(strongSelf.takeResourceResBlock){
                        //那边要冲刷数据
                        strongSelf.takeResourceResBlock(resAssetModel);
                    }
                    
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        };
        _mainView.takeVideoBlock = ^(NSURL * _Nonnull videoUrl) {
            
        };
    }
    return _mainView;
}

@end

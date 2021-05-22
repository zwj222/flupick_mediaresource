//
//  GZSelectAlbumVC.m
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import "GZSelectAlbumVC.h"
#import "GZSelectAlbumView.h"
#import "AliyunAlbumViewController.h"
#import "PickMediasHeader.h"

#import "GZPhotoBrowse.h"

@interface GZSelectAlbumVC ()

@property (nonatomic, strong) GZSelectAlbumView *mainView;

@end

@implementation GZSelectAlbumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mainView];
}

- (GZSelectAlbumView *)mainView{
    if (!_mainView) {
        __weak typeof(self) weakSelf = self;
        _mainView = [GZSelectAlbumView createGZSelectAlbumView];
        _mainView.popBlock = ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.navigationController dismissViewControllerAnimated:YES completion:^{ }];
        };
        
        //相册列表
        _mainView.takingPhotoBlock = ^(UIButton * _Nonnull sender) {
            __strong typeof(self) strongSelf = weakSelf;
            
            AliyunAlbumViewController *vc = [[AliyunAlbumViewController alloc] init];
            vc.albumTitle = sender.titleLabel.text;
            vc.selectBlock = ^(AliyunAlbumModel *albumModel) {
                //把页面的标题换成切换后的相册名称
                [sender setTitle:albumModel.albumName forState:UIControlStateNormal];
                //发送通知，将albumModel带过去
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAlbumAndVideo" object:albumModel];
            };
            
            [strongSelf.navigationController pushViewController:vc animated:YES];
        };
        
        _mainView.selectedAndConfirmUseBlock = ^(NSArray<AliyunAssetModel *> * _Nonnull resArr) {
            __strong typeof(self) strongSelf = weakSelf;
            
            GZPhotoBrowse *vc = [GZPhotoBrowse new];
            //确定使用的话，回调？暴露最后的结果出去
            vc.confirmUseResourceBlock = ^{
                //这个把结果暴露到最外面调用选资源的地方
                if (strongSelf.selectedAndConfirmUseResourceBlock) {
                    strongSelf.selectedAndConfirmUseResourceBlock(resArr);
                }
            };
            vc.isBrower = NO;
            vc.selectIndex = 0;
            vc.totalArray = resArr;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        };
    }
    return _mainView;
}

#pragma mark - 找到当前view所在的控制器
- (UIViewController *)findViewController:(UIView *)sourceView{
    id target = sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end

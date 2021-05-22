//
//  GZVideoCompletVC.m
//  CommunityDemo
//
//  Created by soco on 2021/5/6.
//

#import "GZVideoCompletVC.h"
#import "PTXPlayMovieView.h"
#import "PickMediasHeader.h"

@interface GZVideoCompletVC ()

//拍视频成功之后显示
@property (nonatomic, strong) PTXPlayMovieView *playMovieView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImgV;

@end

@implementation GZVideoCompletVC

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.playMovieView pause];
    self.playMovieView = nil;
    
    if (self.popBlock) {
        self.popBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isPhoto) {
        //拍照
        self.photoImgV.hidden = NO;
        self.photoImgV.image = self.photoImg;
        
    } else {//视频
        self.photoImgV.hidden = YES;

        self.playMovieView.fileUrl = self.recodingUrl;
        [self.playMovieView play];
        [self.view addSubview:self.playMovieView];
    }
}

#pragma mark - PTXPlayMovieViewDelegate
#pragma mark 发送录像
- (void)didClickSendButtonInPlayView:(PTXPlayMovieView *)playMovieView {
//    [self.playMovieView pause];
    
//    GZShoppingMallTwoVideosViewController *vc = [GZShoppingMallTwoVideosViewController new];
//
//    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (PTXPlayMovieView *)playMovieView{
    if (!_playMovieView) {
        _playMovieView = [[PTXPlayMovieView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    };
    return _playMovieView;
}

@end

//
//  GZSelectAlbumView.m
//  YTWaterFlowLayoutDemo
//
//  Created by soco on 2021/4/29.
//  Copyright © 2021 guojunwei. All rights reserved.
//

#import "GZSelectAlbumView.h"
#import "GZAllAlbumAndVideoView.h"

#import "PickMediasHeader.h"

@interface GZSelectAlbumView ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *allListBtn;

@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *albumBtn;
@property (nonatomic, strong) UIView *underLine;
@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) GZAllAlbumAndVideoView *allView;

//预览按钮
@property (nonatomic, strong) UIButton *previewBtn;
//已完成按钮
@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation GZSelectAlbumView

+ (instancetype)createGZSelectAlbumView{
    return [[NSBundle mainBundle] loadNibNamed:@"GZSelectAlbumView" owner:self options:nil][0];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UIImage *backImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"assets_close" ofType:@"png"]];
    [self.backBtn setImage:[UIImage imageCompressForSize:backImage targetSize:CGSizeMake(24, 24)] forState:UIControlStateNormal];
    
    UIImage *all_List_Image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"assets_recent" ofType:@"png"]];
    [self.allListBtn setImage:[UIImage imageCompressForSize:all_List_Image targetSize:CGSizeMake(24, 24)] forState:UIControlStateNormal];
    [self.allListBtn setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
  
    [self addSubview:self.allView];
    [self addSubview:self.underLine];

    [self btnEvents:self.allBtn];
}

- (IBAction)btnEvents:(UIButton *)sender{
    if (sender.isSelected) {
        return;
    }
    self.selectedBtn.selected = NO;
    sender.selected = YES;
    self.selectedBtn = sender;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.underLine.centerX = sender.centerX;
    }];
    
    if (self.allBtn.isSelected) {
        self.allView.type = 0;
    }
    
    if (self.videoBtn.isSelected) {
        self.allView.type = 1;
    }
    
    if (self.albumBtn.isSelected) {
        self.allView.type = 2;
    }
}

- (IBAction)popEvents:(id)sender{
    if (self.popBlock) {
        self.popBlock();
    }
}

- (IBAction)photoListEvents:(UIButton *)sender{
    if (self.takingPhotoBlock) {
        self.takingPhotoBlock(sender);
    }
}

- (IBAction)nestEvents:(UIButton *)sender{
    //下一步的操作 判断有没有选中的？ 应该去浏览选中的，最后确定使用？
    //获取选取的图片或视频
    //这里循环遍历出来选中的
    NSMutableArray *resArr = [NSMutableArray array];
    for (AliyunAssetModel *tmpModel in self.allView.totalSaveArray) {
        if (tmpModel.isSelected) {
            [resArr addObject:tmpModel];
        }
    }
    
    //这个地方是去浏览选择好的资源，如果确定使用，则直接暴露给外面了？ 怎么暴露？
    if (resArr.count > 0) {
        if (self.selectedAndConfirmUseBlock) {
            self.selectedAndConfirmUseBlock(resArr);
        }
    }else{
        //报错返回了
        [MBProgressHUD showMessage:@"请选择相应的资源" inView:self];
        return;
    }
}

- (GZAllAlbumAndVideoView *)allView{
    if (!_allView) {
        _allView = [GZAllAlbumAndVideoView createGZAllAlbumAndVideoView];
        _allView.frame = CGRectMake(0, STATUSHEIGHT + 103, ScreenWidth, self.height - (STATUSHEIGHT + 103));
    }
    return _allView;
}

- (UIView *)underLine{
    if (!_underLine) {
        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(self.allBtn.centerX - 22.5, STATUSHEIGHT + 100, 45, 2)];
        underLine.backgroundColor = rgba(47, 47, 56, 1);
        _underLine = underLine;
    }
    return _underLine;
}

@end

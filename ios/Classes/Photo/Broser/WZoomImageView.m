//
//  WZoomImageView.m
//  ObtainResource
//
//  Created by Willian on 2021/5/7.
//

#import "WZoomImageView.h"
#import "PickMediasHeader.h"

@interface WZoomImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGFloat minimumZoomScale;
@property (nonatomic, assign) CGFloat maximumZoomScale;

@end

@implementation WZoomImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageState = ShowImageStateSmall;
    }
    return self;
}

- (void)initView{
    self.minimumZoomScale = 1.f;
    self.maximumZoomScale = 3.f;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    if(_imageView){
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
}

- (void)addGestures{
    // 1 add double tap gesture
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleClick:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    // 2 add single tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [tap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:tap];
}

#pragma mark - 手势处理 && 事件处理
- (void)tapAction:(UIPanGestureRecognizer *)sender{
    [[self viewController].navigationController popViewControllerAnimated:YES];
}

- (void)didDoubleClick:(UITapGestureRecognizer *)sender{
    if (self.imageState > ShowImageStateSmall) {
        if (self.zoomScale != 1.0) {// 还原
            [self setZoomScale:1.f animated:YES];
        } else {// 放大
            CGPoint point = [sender locationInView:sender.view];
            CGFloat touchX = point.x;
            CGFloat touchY = point.y;
            touchX *= 1/self.zoomScale;
            touchY *= 1/self.zoomScale;
            touchX += self.contentOffset.x;
            touchY += self.contentOffset.y;
            CGRect zoomRect = [self zoomRectForScale:2.f withCenter:CGPointMake(touchX, touchY)];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

#pragma mark - API
- (void)resetScale{
    [self setZoomScale:1.f animated:NO];
}

- (void)showImageWithPhotoImage:(UIImage *)image{
    //重新加载视图
    [self initView];
    [self addGestures];
    
    // 3，加载图片数据
    self.imageView.image = image;
    _imageState = ShowImageStateBig;
}

#pragma mark - 辅助函数
- (void)setupImageView:(UIImage *)image{
    if (!image) {
        return;
    }
    CGFloat scrW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = scrW / image.size.width;
    CGSize size = CGSizeMake(scrW, image.size.height * scale);
    CGFloat y = MAX(0., (self.frame.size.height - size.height) / 2.f);
    CGFloat x = MAX(0., (self.frame.size.width - size.width) / 2.f);
    [self.imageView setFrame:CGRectMake(x, y, size.width, size.height)];
    [self.imageView setImage:image];
    self.contentSize = CGSizeMake(self.bounds.size.width, size.height);
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self centerScrollViewContents];
}

// 缩放小于1的时候，始终让其在中心点位置进行缩放
- (void)centerScrollViewContents{
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}


@end

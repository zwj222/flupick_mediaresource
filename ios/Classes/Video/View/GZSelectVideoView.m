//
//  GZSelectVideoView.m
//  CommunityDemo
//
//  Created by soco on 2021/4/30.
//

#import "GZSelectVideoView.h"
#import <AVFoundation/AVFoundation.h>

#import "PTXTakePhotosView.h"
#import "PTXFocusCursorView.h"
#import "GZVideoCompletVC.h"
#import "PickMediasHeader.h"

#import "AliyunPhotoLibraryManager.h"

@interface GZSelectVideoView ()<PTXTakePhotosViewDelegate>{
    AVCaptureDeviceInput *captureDeviceInput; //负责从设备(AVCaptureDevice)中获得输入。
    AVCaptureStillImageOutput *captureStillImageOutput; //照片输出。
    AVCaptureMovieFileOutput *captureMovieFileOutput; //视频输出。
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; //图像预览层，实时显示捕获的图像。
    
    AVCaptureFlashMode captureFlashMode;
    
    NSURL *_recodingUrl;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;
@property (weak, nonatomic) IBOutlet UIButton *taggerCameraBtn;

//聚焦
@property (nonatomic, strong) PTXFocusCursorView *focusCursorView;
@property (nonatomic, strong) UIView *cameraView;
//时间Lab
@property (nonatomic, strong) UILabel *timeLab;

//录制视频按钮
@property (nonatomic, strong) PTXTakePhotosView *takePhotosView;

//负责输入和输出设备之间的数据交互。
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation GZSelectVideoView

+ (instancetype)createGZSelectVideoView{
    return [[NSBundle mainBundle] loadNibNamed:@"GZSelectVideoView" owner:self options:nil][0];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UIImage *backImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"assets_close" ofType:@"png"]];
    [self.closeBtn setImage:[UIImage imageCompressForSize:backImage targetSize:CGSizeMake(24, 24)] forState:UIControlStateNormal];
    
    UIImage *flashImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"assets_flash" ofType:@"png"]];
    [self.flashBtn setImage:[UIImage imageCompressForSize:flashImage targetSize:CGSizeMake(24, 24)] forState:UIControlStateNormal];
    
    UIImage *reserveImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"assets_reserve" ofType:@"png"]];
    [self.taggerCameraBtn setImage:[UIImage imageCompressForSize:reserveImage targetSize:CGSizeMake(24, 24)] forState:UIControlStateNormal];
    
    self.closeBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.closeBtn.layer.cornerRadius = 18;
    self.closeBtn.imageEdgeInsets = UIEdgeInsetsMake(1, 0, -1, 0);
    
    self.flashBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.flashBtn.layer.cornerRadius = 18;
    self.flashBtn.imageEdgeInsets = UIEdgeInsetsMake(1, 0, -1, 0);
    
    self.taggerCameraBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.taggerCameraBtn.layer.cornerRadius = 18;
    self.taggerCameraBtn.imageEdgeInsets = UIEdgeInsetsMake(1, 0, -1, 0);

    
    if (!captureDeviceInput) {
        CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion > 9.0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"获取摄像头失败" message:@"该设备不存在或无法获取摄像头" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了确定");
            }]];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取摄像头失败" message:@"该设备不存在或无法获取摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else {
        //显示光标。
        CGPoint point = self.center;
        CGPoint cameraPoint = [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:self.center]; //把中心点转换为预览图层上的位置。
        [self setFocusCursorWithPoint:point];
        [self focusWithModel:AVCaptureFocusModeAutoFocus exposureModel:AVCaptureExposureModeAutoExpose point:cameraPoint];
    }
    
    [self setupCameraView];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupCaptureSession];
    });
}
    

- (IBAction)popVC:(id)sender{
    if (self.popBlock) {
        self.popBlock();
    }
}

#pragma mark 相机UI
- (void)setupCameraView{
    [self insertSubview:self.cameraView atIndex:0];
    [self addSubview:self.timeLab];
    [self addSubview:self.takePhotosView];
}

- (void)setupCaptureSession{
    //初始会话。
    _captureSession = [[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720]; //设置分辨率。
    }
    
    //初始化视频输入对象。
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        NSLog(@"获取后置摄像头时出现问题。");
        return;
    }
    NSError *error = nil;
    captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"获取设备输入对象时出现问题。");
        return;
    }
    captureFlashMode = AVCaptureFlashModeOff;
    [self setCaptureDeviceFlashModel:AVCaptureFlashModeOff]; //默认关闭闪光灯。
    
    //初始化音频输入对象。
    AVCaptureDevice *audioCatureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio]firstObject];
    error = nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCatureDevice error:&error];
    if (error) {
        NSLog(@"获取设备输入对象时出现问题。");
        return;
    }
    
    //初始化输出。
    captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    //添加输入输出到会话中。
    if ([_captureSession canAddInput:captureDeviceInput]) {
        [_captureSession addInput:captureDeviceInput];
    }
    if ([_captureSession canAddInput:audioCaptureDeviceInput]) {
        [_captureSession addInput:audioCaptureDeviceInput];
    }
    if ([_captureSession canAddOutput:captureStillImageOutput]) {
        [_captureSession addOutput:captureStillImageOutput];
    }
    if ([_captureSession canAddOutput:captureMovieFileOutput]) {
        [_captureSession addOutput:captureMovieFileOutput];
    }
    
    //初始化图像预览层。
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    captureVideoPreviewLayer.frame = _cameraView.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_cameraView.layer insertSublayer:captureVideoPreviewLayer atIndex:0];
    
    [_captureSession startRunning];
}

#pragma mark 拍照
- (void)didTriggerTakePhotosInView:(PTXTakePhotosView *)takePhotosView{
    //根据设备输出获得连接。
    AVCaptureConnection *captureConnection = [captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        NSLog(@"拍照失败！");
        return;
    }
    
    [captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            NSLog(@"获取照片失败！");
            return;
        }
        [_captureSession stopRunning];
        
        //获取图片的数据
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *resImage = [UIImage imageWithData:imageData];
        if (self.takePicBlock) {
            self.takePicBlock(resImage);
        }
        
//        GZVideoCompletVC *vc = [GZVideoCompletVC new];
//        vc.isPhoto = YES;
//        vc.photoImg = [UIImage imageWithData:imageData];
//        vc.popBlock = ^{
//            [_captureSession startRunning];
//        };
//        [[self viewController].navigationController pushViewController:vc animated:YES];
        
    }];
}

#pragma mark 开始录像
- (void)beganRecordingVieoInView:(PTXTakePhotosView *)takePhotosView{
    self.timeLab.text = @"0.0s";
    
    //根据设备输出获得连接。
    AVCaptureConnection *captureConnection = [captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        NSLog(@"录像失败！");
        return;
    }
    
    if (![captureMovieFileOutput isRecording]) {
        NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingString:@"tempMovie.mov"];
        NSLog(@"recoding movie path is: %@",outputFilePath);
        _recodingUrl = [NSURL fileURLWithPath:outputFilePath];
        [captureMovieFileOutput startRecordingToOutputFileURL:_recodingUrl recordingDelegate:self];
    }
}

#pragma mark 录制持续时间
- (void)timDuration:(PTXTakePhotosView *)takePhotosView{
    self.timeLab.text = [NSString stringWithFormat:@"%.1fs",takePhotosView.longTime];
}

#pragma mark 结束录像
- (void)endRecordingVieoInView:(PTXTakePhotosView *)takePhotosView{
    [self endRecordingVieo];
}

- (IBAction)flashTagger:(UIButton *)sender {
    if (captureFlashMode == AVCaptureFlashModeOff) {
        //闪光
        captureFlashMode = AVCaptureFlashModeOn;
        [self setCaptureDeviceFlashModel:AVCaptureFlashModeOn]; //默认关闭闪光灯。
        [MBProgressHUD showMessage:@"切换成功" inView:self];
    }else{
        //关闭闪光
        captureFlashMode = AVCaptureFlashModeOff;
        [self setCaptureDeviceFlashModel:AVCaptureFlashModeOff]; //默认关闭闪光灯。
        [MBProgressHUD showMessage:@"切换成功" inView:self];
    }
}


- (IBAction)cameraTagger:(UIButton *)sender {
    //切换前后摄像头
    //获取摄像头的数量（该方法会返回当前能够输入视频的全部设备，包括前后摄像头和外接设备）
    NSInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    //摄像头的数量小于等于1的时候直接返回
    if (cameraCount <= 1) {
        return;
    }
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //获取当前相机的方向（前/后）
    AVCaptureDevicePosition position = [[captureDeviceInput device] position];
 
    //为摄像头的转换加转场动画
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
 
    if (position == AVCaptureDevicePositionFront) {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
 
    }else if (position == AVCaptureDevicePositionBack){
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    [captureVideoPreviewLayer addAnimation:animation forKey:nil];
 
    //输入流
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    if (newInput != nil) {
        //先移除原来的input
        [self.captureSession removeInput:captureDeviceInput];
        if ([self.captureSession canAddInput:newInput]) {
            [self.captureSession addInput:newInput];
            captureDeviceInput = newInput;
        }else{
            //如果不能加现在的input，就加原来的input
            [self.captureSession addInput:captureDeviceInput];
        }
        [self.captureSession commitConfiguration];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}


#pragma mark - Private Methods
- (void)setCaptureDeviceFlashModel:(AVCaptureFlashMode)model{
    AVCaptureDevice *captureDevice = [captureDeviceInput device];
    NSError *error;
    //改变设备属性前一定先要上锁，设置完之后再解锁。
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFlashModeSupported:model]) {
            [captureDevice setFlashMode:model];
        }
        [captureDevice unlockForConfiguration];
    }else {
        NSLog(@"设置闪光灯模式发生错误，错误信息:%@",error.localizedDescription);
    }
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

#pragma mark 获取聚焦点。
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //限制点击的范围，防止光标与拍照按钮重叠。
    if (point.y > CGRectGetMidY(self.timeLab.frame) - 40.0) {
        return;
    }
    
    if (point.y < 64.0) {
        return;
    }
    //把当前点转换为预览图层上的点。
    CGPoint cameraPoint = [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    
    [self setFocusCursorWithPoint:point];
    [self focusWithModel:AVCaptureFocusModeAutoFocus exposureModel:AVCaptureExposureModeAutoExpose point:cameraPoint];
}

#pragma mark 设置聚焦和曝光。
- (void)focusWithModel:(AVCaptureFocusMode)focusModel exposureModel:(AVCaptureExposureMode)exposureModel point:(CGPoint)point{
    AVCaptureDevice *captureDevice = [captureDeviceInput device];
    NSError *error = nil;
    if ([captureDevice lockForConfiguration:&error]) {
        //设置聚焦。
        if ([captureDevice isFocusModeSupported:focusModel]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        //设置曝光
        if ([captureDevice isExposureModeSupported:exposureModel]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
        
        [captureDevice unlockForConfiguration];
    }else {
        NSLog(@"设置聚焦发生错误，错误信息:%@",error.localizedDescription);
    }
}

#pragma mark 显示光标位置。
- (void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursorView.center = point;
    self.focusCursorView.alpha = 1.0;
    self.focusCursorView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.2 animations:^{
        self.focusCursorView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:3.0 animations:^{
        self.focusCursorView.alpha = 0;
    }];
}

//视频录制完成
- (void)endRecordingVieo{
    self.timeLab.text = @"单击拍照，长按拍视频";
    
    if ([captureMovieFileOutput isRecording]) {
        [captureMovieFileOutput stopRecording];
    }
    [_captureSession stopRunning];
    
    //保存视频
    if (self.takeVideoBlock) {
        self.takeVideoBlock(_recodingUrl);
    }
    
    //直接返回上一个页面
    
//    GZVideoCompletVC *vc = [GZVideoCompletVC new];
//    vc.isPhoto = NO;
//    vc.recodingUrl = _recodingUrl;
//    vc.popBlock = ^{
//        [_captureSession startRunning];
//    };
//    [[self viewController].navigationController pushViewController:vc animated:YES];
}

//getter
- (PTXFocusCursorView *)focusCursorView {
    if (!_focusCursorView) {
        _focusCursorView = [[PTXFocusCursorView alloc] initWithFrame:CGRectMake(0, 0, 80.0, 80.0)];
        [self addSubview:_focusCursorView];
    }
    return _focusCursorView;
}

- (UILabel *)timeLab{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, ScreenHeight - 44 - 170 , ScreenWidth, 20)];
        _timeLab.backgroundColor = [UIColor clearColor];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.font = [UIFont systemFontOfSize:13.0];
        _timeLab.textColor = [UIColor whiteColor];
        _timeLab.text = @"单击拍照，长按拍视频";
    }
    return _timeLab;
}

- (PTXTakePhotosView *)takePhotosView{
    if (!_takePhotosView) {
        _takePhotosView = [[PTXTakePhotosView alloc] initWithFrame:CGRectMake((ScreenWidth - 80.0) / 2, self.timeLab.bottom + 20, 80.0, 80.0)];
        _takePhotosView.delegate = self;
    }
    return _takePhotosView;
}

- (UIView *)cameraView{
    if (!_cameraView) {
        _cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _cameraView.backgroundColor = [UIColor blackColor];
    }
    return _cameraView;
}

@end

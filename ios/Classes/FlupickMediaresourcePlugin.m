
#import "FlupickMediaresourcePlugin.h"

#import "GZSelectAlbumVC.h"
#import "GZSelectVideoVC.h"
#import <AVFoundation/AVFoundation.h>

@interface FlupickMediaresourcePlugin (){
    NSDictionary *_arguments;
    UIViewController *_viewController;
}

@property(copy, nonatomic) FlutterResult result;

@end


@implementation FlupickMediaresourcePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"flupick_mediaresource"
            binaryMessenger:[registrar messenger]];
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    FlupickMediaresourcePlugin* instance = [[FlupickMediaresourcePlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (self.result) {
        self.result([FlutterError errorWithCode:@"multiple_request"
                                        message:@"Cancelled by a second request"
                                        details:nil]);
        self.result = nil;
    }

    NSDictionary *dict = call.arguments;
    if ([@"get_mediaResource" isEqualToString:call.method]) {
        NSString *assetType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"assetType"]];

        self.result = result;
        [self handleAssetType:assetType];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleAssetType:(NSString *)assetType {

//    LFImagePickerController *imagePicker = [[LFImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];//这里设置最大选择数，图片和视频的
//    imagePicker.allowTakePicture = YES;
//    imagePicker.allowPickingOriginalPhoto = YES;
//
//    if([assetType isEqualToString:@"assetImageOnly"]) {
//        // 仅图片
//        //仅展示图片
//        imagePicker.allowPickingType = LFPickingMediaTypePhoto;
//    } else if([assetType isEqualToString:@"assetVideoOnly"]) {
//        // 仅视频
//        ///仅展示视频
//        imagePicker.allowPickingType = LFPickingMediaTypeVideo;
//    } else if([assetType isEqualToString:@"assetImageOrVideo"]) {
//        // 图片或视频
//        imagePicker.maxVideosCount = 2;
//    } else if([assetType isEqualToString:@"assetImageAdnVideo"]) {
//        // 图片和视频
//    }
//
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
//        imagePicker.syncAlbum = YES; /** 实时同步相册 */
//    }
//    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
//    [_viewController presentViewController:imagePicker animated:YES completion:nil];



//    GZSelectVideoVC *vc = [[GZSelectVideoVC alloc] initWithFromWhat:@"flutter" isOnlyAllowTakePhoto:true takeResourceResBlock:^(NSString * _Nonnull path, BOOL isPhoto) {
//
//    }];
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
//    [navVC setNavigationBarHidden:YES animated:NO];
//    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
//    [_viewController presentViewController:navVC animated:YES completion:nil];


    GZSelectAlbumVC *vc = [GZSelectAlbumVC new];
    //这里怎么拿到结果呢？
    __weak typeof(vc) weakVC = vc;
    vc.selectedAndConfirmUseResourceBlock = ^(NSArray<AliyunAssetModel *> * _Nonnull resArr) {
        __strong typeof(vc) strongVC = weakVC;
        
        //这里用dispatch_group来做
        [self syncObtainResourceUrlsWithAssetsModels:resArr curVC:strongVC];
    };
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [navVC setNavigationBarHidden:YES animated:NO];
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [_viewController presentViewController:navVC animated:YES completion:nil];

}


- (void)syncObtainResourceUrlsWithAssetsModels:(NSArray<AliyunAssetModel *> * )resArr curVC:(GZSelectAlbumVC *)curVC{
    //返回结果的数组
    NSMutableArray *resToFlutterArr = [NSMutableArray arrayWithCapacity:0];

    dispatch_queue_t disqueue = dispatch_queue_create("com.willian.obtainResourceUrls", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t disgroup = dispatch_group_create();

    for (NSInteger i = 0; i < resArr.count; i++) {
        //进入组
        dispatch_group_enter(disgroup);

        AliyunAssetModel *model = resArr[i];
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];

        //开始做异步操作
        if (model.type == AliyunAssetModelMediaTypeVideo) {
            
            //PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset: model.asset] firstObject];

            //这个资源是视频的话
            [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:model.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
                //拿到avAsset  直接强转成AVURLAsset， 再拿它的url来播放
                AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                NSMutableString *path = [urlAsset.URL.absoluteString mutableCopy];
                [tmpDic setValue:[path stringByReplacingOccurrencesOfString:@"file://" withString:@""] forKey:@"path"];
                [tmpDic setValue:@"video" forKey:@"type"];

                //拿到一个资源就保存到数组里面
                [resToFlutterArr addObject:tmpDic];
                dispatch_group_leave(disgroup);
            }];
        }else if (model.type == AliyunAssetModelMediaTypePhoto){
            [model.asset requestContentEditingInputWithOptions:[PHContentEditingInputRequestOptions new] completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                NSURL *url = contentEditingInput.fullSizeImageURL;
                NSMutableString *path = [url.absoluteString mutableCopy];
                [tmpDic setValue:[path stringByReplacingOccurrencesOfString:@"file://" withString:@""] forKey:@"path"];
                [tmpDic setValue:@"image" forKey:@"type"];
                
                //拿到一个资源就保存到数组里面
                [resToFlutterArr addObject:tmpDic];
                dispatch_group_leave(disgroup);
            }];
        }
    }
    
    dispatch_group_notify(disgroup, disqueue, ^{
        NSLog(@"上面的异步任务完成了，后面可以返回了");
        dispatch_async(dispatch_get_main_queue(), ^{
            //最后转化成外面想要的数据
            self.result(resToFlutterArr);

            //选择资源的界面要关掉了
            [curVC.navigationController dismissViewControllerAnimated:YES completion:^{}];
        });
    });
}


@end



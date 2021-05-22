//
//  AliyunPhotoLibraryManager.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPhotoLibraryManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;

static BOOL iOS9Later;
//static CGSize kAssetGridThumbnailSize;
//static CGFloat kQUScreenWidth;
static CGFloat kQUScreenScale;

@interface AliyunPhotoLibraryManager ()

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@end

@implementation AliyunPhotoLibraryManager

+ (instancetype)sharedManager {
    static AliyunPhotoLibraryManager *mg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mg = [[self alloc] init];
        mg.cachingImageManager = [[PHCachingImageManager alloc] init];
        iOS9Later = ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f);
        kQUScreenScale = 2.0;
    });
    return mg;
}

- (BOOL)authorizationStatusAuthorized {
    return [self authorizationStatus] == 3;
}

- (NSInteger)authorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

- (void)requestAuthorization:(void (^)(BOOL authorization))completion {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == 3) {
            completion(YES);
        }else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController *alertController =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请开启相册访问权限", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 =[UIAlertAction actionWithTitle:NSLocalizedString(@"取消" , nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    UINavigationController* rootNav = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                    [rootNav popViewControllerAnimated:YES];
                }];
                UIAlertAction *action2 =[UIAlertAction actionWithTitle:NSLocalizedString(@"开启", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];

                [alertController addAction:action1];
                [alertController addAction:action2];
                [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            });
        }
    }];
}


//询问相机权限
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 获取 当前 App 对 phots 的访问权限
    PHAuthorizationStatus OldStatus = [PHPhotoLibrary authorizationStatus];

    // 检查访问权限 当前 App 对相册的检查权限
    /**
     * PHAuthorizationStatus
     * PHAuthorizationStatusNotDetermined = 0, 用户还未决定
     * PHAuthorizationStatusRestricted,        系统限制，不允许访问相册 比如家长模式
     * PHAuthorizationStatusDenied,            用户不允许访问
     * PHAuthorizationStatusAuthorized         用户可以访问
     * 如果之前已经选择过，会直接执行 block，并且把以前的状态传给你
     * 如果之前没有选择过，会弹框，在用户选择后调用 block 并且把用户的选择告诉你
     * 注意：该方法的 block 在子线程中运行 因此，弹框什么的需要回到主线程执行
     */
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                //            [self cSaveToCameraRoll];
                //            [self photoSaveToCameraRoll];
                //            [self fetchCameraRoll];
                //            [self createCustomAssetCollection];
                //            [self createdAsset];
                //            [self saveImageToCustomAlbum2];
                //[self saveImageToCustomAlbum1];
            } else if (OldStatus != PHAuthorizationStatusNotDetermined && status == PHAuthorizationStatusDenied) {
                // 用户上一次选择了不允许访问 且 这次又点击了保存 这里可以适当提醒用户允许访问相册
            }
        });
    }];
}

#pragma mark - 将图片保存到自定义相册中 第一种写法 比较规范
- (void)saveImage:(UIImage *)image toAlbem:(AliyunAlbumModel *)albumModel completion:(void (^)(NSError *, AliyunAssetModel *))completion{
    // 获取保存到相机胶卷中的图片
    PHAsset *createdAsset = [self createdAssetsWithImage:image].firstObject;
    if (createdAsset == nil) {
        NSLog(@"保存图片失败");
    }
    // 获取自定义相册
    PHAssetCollection *createdCollection = [self obtainAssetCollectionWithAlbem:albumModel];
    if (createdCollection == nil) {
        NSLog(@"创建相册失败");
    }

    NSError *error = nil;
    // 将图片保存到自定义相册
    /**
     * 必须通过中间类，PHAssetCollectionChangeRequest 来完成
     * 步骤：1.首先根据相册获取 PHAssetCollectionChangeRequest 对象
     *      2.然后根据 PHAssetCollectionChangeRequest 来添加图片
     * 这一步的实现有两个思路：1.通过上面的占位 asset 的标识来获取 相机胶卷中的 asset
     *                       然后，将 asset 添加到 request 中
     *                     2.直接将 占位 asset 添加到 request 中去也是可行的
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        if([createdCollection canPerformEditOperation:PHCollectionEditOperationAddContent]){
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
            [request insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
        }else{
            NSLog(@"不能操作");
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            completion(error, nil);
        } else {
            AliyunAssetModel *resAssetModel = [AliyunAssetModel modelWithAsset:createdAsset type:AliyunAssetModelMediaTypePhoto];
            completion(nil, resAssetModel);
        }
    }];
    
//    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
//        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
//        [request insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
//    } error:&error];
//
//    AliyunAssetModel *resAssetModel = [AliyunAssetModel modelWithAsset:createdAsset type:AliyunAssetModelMediaTypePhoto];
//    completion(nil, resAssetModel);
//
//    if (error) {
//        completion(error, nil);
//    } else {
//        AliyunAssetModel *resAssetModel = [AliyunAssetModel modelWithAsset:createdAsset type:AliyunAssetModelMediaTypePhoto];
//        completion(nil, resAssetModel);
//    }
}

#pragma mark - 获取保存到【相机胶卷】的图片
- (PHFetchResult<PHAsset *> *)createdAssetsWithImage:(UIImage *)image{
    // 将图片保存到相机胶卷
    NSError *error = nil;
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) return nil;
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}

#pragma mark - 使用 photo 框架创建自定义名称的相册 并获取自定义到自定义相册
- (PHAssetCollection *)obtainAssetCollectionWithAlbem:(AliyunAlbumModel *)albem{
    NSError *error = nil;
    // 查找 app 中是否有该相册 如果已经有了 就不再创建
    /**
     *     参数一 枚举：
     *     PHAssetCollectionTypeAlbum      = 1, 用户自定义相册
     *     PHAssetCollectionTypeSmartAlbum = 2, 系统相册
     *     PHAssetCollectionTypeMoment     = 3, 按时间排序的相册
     *
     *     参数二 枚举：PHAssetCollectionSubtype
     *     参数二的枚举有非常多，但是可以根据识别单词来找出我们想要的。
     *     比如：PHAssetCollectionTypeSmartAlbum 系统相册 PHAssetCollectionSubtypeSmartAlbumUserLibrary 用户相册 就能获取到相机胶卷
     *     PHAssetCollectionSubtypeAlbumRegular 常规相册
     */
    
    VideoDurationRange duration = {0.0, 0.0};
    
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [self configurePredicateWithAllowImage:YES allowVideo:YES range:duration];
    
    if (!self.sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            if ([collection.localIdentifier isEqualToString:albem.localIdentifier]) {
                return collection;
            }
        }
    }
    
    return nil;
//    [[AliyunPhotoLibraryManager sharedManager] getAllAlbums:YES allowPickingImage:YES durationRange:duration completion:^(NSArray<AliyunAlbumModel *> *models) {
//        for (AliyunAlbumModel *collection in models) {
//            if ([collection.localIdentifier isEqualToString:albem.localIdentifier]) { // 说明 app 中存在该相册
//                return collection;
//            }
//        }
//    }];
    

    /** 来到这里说明相册不存在 需要创建相册 **/
    __block NSString *createdCustomAssetCollectionIdentifier = nil;
    // 创建和 app 名称一样的 相册
    /**
     * 注意：这个方法只是告诉 photos 我要创建一个相册，并没有真的创建
     *      必须等到 performChangesAndWait block 执行完毕后才会
     *      真的创建相册。
     */
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albem.albumName];
        /**
         * collectionChangeRequest 即使我们告诉 photos 要创建相册，但是此时还没有
         * 创建相册，因此现在我们并不能拿到所创建的相册，我们的需求是：将图片保存到
         * 自定义的相册中，因此我们需要拿到自己创建的相册，从头文件可以看出，collectionChangeRequest
         * 中有一个占位相册，placeholderForCreatedAssetCollection ，这个占位相册
         * 虽然不是我们所创建的，但是其 identifier 和我们所创建的自定义相册的 identifier
         * 是相同的。所以想要拿到我们自定义的相册，必须保存这个 identifier，等 photos app
         * 创建完成后通过 identifier 来拿到我们自定义的相册
         */
        createdCustomAssetCollectionIdentifier = collectionChangeRequest.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];

    // 这里 block 结束了，因此相册也创建完毕了
    if (error) return nil;
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCustomAssetCollectionIdentifier] options:nil].firstObject;
}



#pragma mark --- 保存资源
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    if (iOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    //这里获取PHAsset，在创建AliyunAssetModel, 然后返回去
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
    } else {
        [self.assetLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:[self orientationFromImage:image] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"保存图片失败:%@",error.localizedDescription);
                if (completion) {
                    completion(error);
                }
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        }];
    }
}

- (void)saveVideoAtUrl:(NSURL *)videoURL toAlbumName:(NSString *)albumName completion:(void (^)(NSError *error))completion {
    [self saveVideoAtUrl:videoURL completion:completion];
}

- (void)saveVideoAtUrl:(NSURL *)videoURL completion:(void (^)(NSError *error))completion {
    if (iOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    NSLog(@"保存成功");
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存视频失败:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
    } else {
        [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"保存视频失败:%@",error.localizedDescription);
                if (completion) {
                    completion(error);
                }
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"保存成功");
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        }];
    }
}

#pragma mark --- 获取具体资源
- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailImage:(BOOL)isThumbnail
               photoWidth:(CGFloat)photoWidth
               completion:(void (^)(UIImage *, NSDictionary *))completion {
    
        
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize size;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    PHImageContentMode contentMode = 0;
    if (isThumbnail) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat dimension = photoWidth;
        size = CGSizeMake(dimension * scale, dimension * scale);
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        contentMode = 1;
    } else {
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {

        };
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = photoWidth * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        size = CGSizeMake(pixelWidth, pixelHeight);
        contentMode = PHImageContentModeAspectFit;
    }
    
    if (phAsset.representsBurst) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
        fetchOptions.includeAllBurstAssets = YES;
        PHFetchResult *burstSequence = [PHAsset fetchAssetsWithBurstIdentifier:phAsset.burstIdentifier options:fetchOptions];
        phAsset = burstSequence.firstObject;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:size contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        BOOL downloadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//        if (downloadFinished) {
            completion(result,info);
//        }
    }];
}


- (void)getPhotoWithAsset:(PHAsset *)asset thumbnailWidth:(CGFloat)width completion:(void (^)(UIImage *image, UIImage *thumbnailImage, NSDictionary *info))completion {
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize size = CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = width;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize thumbnailSize = CGSizeMake(pixelWidth, pixelHeight);

    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset
                                               targetSize:size
                                              contentMode:PHImageContentModeDefault
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            
            @autoreleasepool {
                UIImage *thumbnailImage = [self imageWithImage:result scaledToSize:thumbnailSize];
                completion(result, thumbnailImage, info);
            }
        }
    }];
}

- (void)saveGifWithAsset:(PHAsset *)asset maxSize:(CGSize)maxSize outputPath:(NSString *)path completion:(void (^)(NSError *error))completion {
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.synchronous = YES;
//    options.networkAccessAllowed = YES;
//    options.resizeMode = PHImageRequestOptionsResizeModeFast;
//    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        if(completion) {
//            [imageData writeToFile:path atomically:YES];
//            completion(nil);
//        }
//    }];
    NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
    if(!resourceList.count) {
        completion([NSError errorWithDomain:@"com.aliyun.photo" code:111 userInfo:nil]);
        return;
    }
    PHAssetResource *resource = [resourceList firstObject];
    PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    if ([resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"]) {
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:path] options:option completionHandler:^(NSError * _Nullable error) {
            if (error) {
                completion(error);
            } else {
                completion(nil);
            }
        }];
    }else {
        completion([NSError errorWithDomain:@"com.aliyun.photo" code:111 userInfo:nil]);
    }
}

- (void)savePhotoWithAsset:(PHAsset *)asset maxSize:(CGSize)maxSize outputPath:(NSString *)path completion:(void (^)(NSError *error, UIImage * _Nullable result))completion {
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    requestOptions.networkAccessAllowed = YES;//打开网络获取iCloud的图片的功能
    CGFloat factor = MAX(maxSize.width,maxSize.height)/MAX(asset.pixelWidth, asset.pixelHeight);
    if (factor > 1) {
        factor = 1.0f;
    }
    // 最终分辨率必须为偶数
    CGFloat outputWidth = rint(asset.pixelWidth * factor / 2 ) * 2;
    CGFloat outputHeight = rint(asset.pixelHeight * factor / 2) * 2;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(outputWidth, outputHeight)
                                              contentMode:PHImageContentModeDefault
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if (completion) {
                                                    
                                                    @autoreleasepool {
                                                        if (!result) {
                                                            completion([NSError errorWithDomain:@"com.aliyun.photo" code:101 userInfo:nil],nil);
                                                        }else {
                                                            if (result.imageOrientation != UIImageOrientationUp) {
                                                                UIGraphicsBeginImageContextWithOptions(result.size, NO, result.scale);
                                                                [result drawInRect:(CGRect){0, 0, result.size}];
                                                                UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
                                                                UIGraphicsEndImageContext();
                                                                 result = normalizedImage;
                                                            }
                                                            NSData *imageData = UIImageJPEGRepresentation(result, 1);
                                                             [imageData writeToFile:path atomically:YES];
                                                            completion(nil,result);
                                                        }
                                                    }
                                                }
                                            }];
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    
    {
        CGSize imageSize;
//        if (photoWidth < kQUScreenWidth && photoWidth < _photoPreviewMaxWidth) {
//            imageSize = kAssetGridThumbnailSize;
//        } else {
            PHAsset *phAsset = (PHAsset *)asset       ;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * kQUScreenScale;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
//        }
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
//                result = [self fixOrientation:result];
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            // Download image from iCloud / 从iCloud下载图片
//            if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
//                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (progressHandler) {
//                            progressHandler(progress, error, stop, info);
//                        }
//                    });
//                };
//                options.networkAccessAllowed = YES;
//                options.resizeMode = PHImageRequestOptionsResizeModeFast;
//                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//                    resultImage = [self scaleImage:resultImage toSize:imageSize];
//                    if (resultImage) {
//                        resultImage = [self fixOrientation:resultImage];
//                        if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
//                    }
//                }];
//            }
        }];
        return imageRequestID;
    }
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

#pragma mark --- 获取相册资源

// 相册封面
- (void)getPostImageWithAlbumModel:(AliyunAlbumModel *)model completion:(void (^)(UIImage *))completion {
    PHAsset *asset = [model.fetchResult lastObject];
    if (!self.sortAscendingByModificationDate) {
        asset = [model.fetchResult firstObject];
    }
    [self getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) completion(photo);
    }];
}

- (void)getCameraRollAssetWithallowPickingVideo:(BOOL)allowPickingVideo
                         allowPickingImage:(BOOL)allowPickingImage
                                  durationRange:(VideoDurationRange)range
                                completion:(void (^)(NSArray<AliyunAssetModel *> *models, NSInteger videoCount, AliyunAlbumModel *albemModel))completion {
    NSInteger videoCount;
    __block NSArray *photoArray;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO],
                               [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]
                               ];

    option.predicate = [self configurePredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo range:range];
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:option];
    videoCount = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    [self getAssetsFromFetchResult:fetchResult allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<AliyunAssetModel *> *models) {
        //对models进行排序
        if (models.count>0) {
            NSMutableArray *arr = models.mutableCopy;
            //TODO 苹果官方并未提供添加相册时间，这里根据缩略图index排序
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"asset.thumbnailIndex" ascending:NO];
            [arr sortUsingDescriptors:@[sort]];
            photoArray = (NSArray *)arr;
        }else{
            photoArray = (NSArray *)models;
        }
    }];
    if (completion) {
        //这里再打包一个 AliyunAlbumModel?
        AliyunAlbumModel *albemModel;
        if ([self isCameraRollAlbum:cameraRoll.localizedTitle]) {
            albemModel = [[AliyunAlbumModel alloc] initWithFetchResult:fetchResult albumName:cameraRoll.localizedTitle localIdentifier:cameraRoll.localIdentifier];
        } else {
            albemModel = [[AliyunAlbumModel alloc] initWithFetchResult:fetchResult albumName:cameraRoll.localizedTitle localIdentifier:cameraRoll.localIdentifier];
        }
        completion(photoArray,videoCount, albemModel);
    }
}

- (void)getAllAlbums:(BOOL)allowPickingVideo
   allowPickingImage:(BOOL)allowPickingImage
       durationRange:(VideoDurationRange)range
          completion:(void (^)(NSArray<AliyunAlbumModel *> *models))completion {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *albumArr = [NSMutableArray array];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        
        option.predicate = [self configurePredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo range:range];
        
        if (!self.sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
        
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (fetchResult.count < 1) continue;
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:NSLocalizedString(@"最近删除", nil)]) continue;
                
                if ([self isCameraRollAlbum:collection.localizedTitle]) {
                    AliyunAlbumModel *model = [[AliyunAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle localIdentifier:collection.localIdentifier];
                    [albumArr insertObject:model atIndex:0];
                } else {
                    AliyunAlbumModel *model = [[AliyunAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle localIdentifier:collection.localIdentifier];
                    [albumArr addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion && albumArr.count > 0) completion(albumArr);
        });
    });
}

- (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<AliyunAssetModel *> *models))completion {
    NSMutableArray *photoArr = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AliyunAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) completion(photoArr);
}

- (void)getAssetFromFetchResult:(PHFetchResult *)result
                        atIndex:(NSInteger)index
              allowPickingVideo:(BOOL)allowPickingVideo
              allowPickingImage:(BOOL)allowPickingImage
                     completion:(void (^)(AliyunAssetModel *model))completion {
    
    PHAsset *asset;
    @try {
        asset = result[index];
    }
    @catch (NSException* e) {
        if (completion) completion(nil);
        return;
    }
    AliyunAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
    if (completion) completion(model);
}

- (void)getVideoWithAsset:(PHAsset *)asset
               completion:(void (^)(AVAsset * avAsset, NSDictionary * info))completion {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionCurrent;
    //    options.version = PHVideoRequestOptionsVersionOriginal;
    //    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;//慢视频转换成正常
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    };
    PHAsset *phAsset = (PHAsset *)asset;
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if(([asset isKindOfClass:[AVComposition class]] && ((AVComposition *)asset).tracks.count == 2)){
            //slow motion videos. See Here: https://overflow.buffer.com/2016/02/29/slow-motion-video-ios/
            
            //Output URL of the slow motion file.
            NSString *root = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
             NSString *tempDir = [root stringByAppendingString:@"/com.sdk.demo/temp"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *myPathDocs =  [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeSlowMoVideo-%d.mov",arc4random() % 1000]];
            NSURL *url = [NSURL fileURLWithPath:myPathDocs];
            //Begin slow mo video export
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                        NSURL *URL = exporter.outputURL;
                        AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(asset, nil);
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, exporter.error);
                        });
                    }
                });
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(asset, nil);
            });
        }
    }];
}

- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:NSLocalizedString(@"最近添加", nil)] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:NSLocalizedString(@"相机胶卷", nil)] || [albumName isEqualToString:NSLocalizedString(@"所有照片", nil)] || [albumName isEqualToString:@"All Photos"];
    }
}

- (AliyunAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    AliyunAssetModel *model;
    AliyunAssetModelMediaType type = AliyunAssetModelMediaTypePhoto;
    
    PHAsset *phAsset = (PHAsset *)asset;
    if (phAsset.mediaType == PHAssetMediaTypeVideo){
       type = AliyunAssetModelMediaTypeVideo;
    } else if (phAsset.mediaType == PHAssetMediaTypeAudio){
        type = AliyunAssetModelMediaTypeAudio;
    } else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = AliyunAssetModelMediaTypePhotoGif;
        }
    }

    if (!allowPickingImage && type == AliyunAssetModelMediaTypePhotoGif) return nil;

    if (self.hideWhenCanNotSelect) {
        if (![self isPhotoSelectableWithAsset:phAsset]) {
            return nil;
        }
    }
    model = [AliyunAssetModel modelWithAsset:asset type:type];
    return model;
}

- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}

- (CGSize)photoSizeWithAsset:(id)asset {
    PHAsset *phAsset = (PHAsset *)asset;
    return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
}

- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

- (NSPredicate *)configurePredicateWithAllowImage:(BOOL)image allowVideo:(BOOL)video range:(VideoDurationRange)range {
    NSPredicate *predicate;
    
    
    NSString *imageFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    NSString *videoFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    if (range.min >= 0 && range.max > 0) {
        NSString *rangeForamt = [NSString stringWithFormat:@" && duration >= %d && duration <= %d",range.min, range.max];
        videoFormat = [videoFormat stringByAppendingString:rangeForamt];
    }
    if (image && !video) {
        predicate = [NSPredicate predicateWithFormat:imageFormat];
    } else if (video && !image) {
        predicate = [NSPredicate predicateWithFormat:videoFormat];
    } else if (video && image) {
        NSString *imageAndVideo = [NSString stringWithFormat:@"%@ || (%@)", videoFormat, imageFormat];
        predicate = [NSPredicate predicateWithFormat:imageAndVideo];
    }
    return predicate;
}

- (ALAssetOrientation)orientationFromImage:(UIImage *)image {
    NSInteger orientation = image.imageOrientation;
    return orientation;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
//    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

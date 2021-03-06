//
//  AliyunAlbumModel.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AliyunAssetModelMediaType) {
    AliyunAssetModelMediaTypePhoto = 0,
    AliyunAssetModelMediaTypeLivePhoto,
    AliyunAssetModelMediaTypePhotoGif,
    AliyunAssetModelMediaTypeVideo,
    AliyunAssetModelMediaTypeAudio,
    AliyunAssetModelMediaTypeToRecod

};

@class PHAsset;
@interface AliyunAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;//选中
@property (nonatomic, assign) AliyunAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;
@property (nonatomic, assign) CGFloat assetDuration;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) BOOL fetchThumbnail;
@property (nonatomic, copy) NSURL *videoURL;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(AliyunAssetModelMediaType)type;

@end

@class PHFetchResult;
@interface AliyunAlbumModel : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger assetsCount;
@property (nonatomic, strong) PHFetchResult *fetchResult;

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;
@property (nonatomic, copy)   NSString *localIdentifier;

- (instancetype)initWithFetchResult:(PHFetchResult *)result albumName:(NSString *)albumName localIdentifier:(NSString *)localIdentifier;

@end

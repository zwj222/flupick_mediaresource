import 'dart:convert';
import 'dart:io';

import 'package:flupick_mediaresource/flupick_mediaresource.dart';
import 'config/MediaResourceConfig.dart';
import 'config/MediaResourceMimeType.dart';
import 'json/modle/image_bean_entity.dart';


///图片选择
class MediaResourceSelector {
  factory MediaResourceSelector() => _getInstance();

  static MediaResourceSelector get instance => _getInstance();
  static MediaResourceSelector _instance;

  int _mPictureMimeType = 0;
  int _mMxSelectNum = 5;
  int _mInSelectNum = 1;
  int _sPanCount = 4;
  int _mSelectionMode = 2;
  bool _isPreviewImage = true;
  bool _isPreviewVideo = true;
  bool _mEnablePreviewAudio = true;
  bool _mIsCamera = true;
  bool _mIsZoomAnim = true;
  var _mOpenSound = false;
  int _mWidth = 100;
  int _mHeight = 100;
  bool _msynOrAsy = true;
  bool _mCompress = true;
  bool _mEnableCrop = true;

  MediaResourceMimeType assetsType = MediaResourceMimeType.all;

  MediaResourceSelector._internal() {
    /// 初始化
  }

  static MediaResourceSelector _getInstance() {
    if (_instance == null) {
      _instance = new MediaResourceSelector._internal();
    }
    return _instance;
  }

  ///支持的文件类型可以不可以拍照和录制视频等
  MediaResourceSelector openGallery({MediaResourceMimeType pictureMimeType = MediaResourceMimeType.all}) {
    if (pictureMimeType == MediaResourceMimeType.image) {
      assetsType = MediaResourceMimeType.image;
      _mPictureMimeType = 1;
    } else if (pictureMimeType == MediaResourceMimeType.video) {
      assetsType = MediaResourceMimeType.video;
      _mPictureMimeType = 2;
    }
    return _instance;
  }

  ///最多选择几个
  MediaResourceSelector maxSelectNum({int maxSelectNum = 5}) {
    _mMxSelectNum = maxSelectNum;
    return _instance;
  }

  ///至少选择几个才能点击完成
  MediaResourceSelector minSelectNum({int minSelectNum = 1}) {
    _mInSelectNum = minSelectNum;
    return _instance;
  }

  ///一行几张图片
  MediaResourceSelector imageSpanCount({int imageSpancount = 4}) {
    _sPanCount = imageSpancount;
    return _instance;
  }

  ///多选或者单选： 多选 or 单选PictureConfig.MULTIPLE  多选 PictureConfig.SINGLE)//  单选
  MediaResourceSelector selectionMode(
      {MediaResourceConfig pictureConfig = MediaResourceConfig.MULTIPLE}) {
    if (MediaResourceConfig != null && pictureConfig == MediaResourceConfig.MULTIPLE) {
      _mSelectionMode = 2;
    } else {
      _mSelectionMode = 1;
    }
    return _instance;
  }

  ///是否可预览图片
  MediaResourceSelector previewImage({bool previewImage = true}) {
    _isPreviewImage = previewImage;
    return _instance;
  }

  ///是否可预览视频
  MediaResourceSelector previewVideo({bool previewVideo = true}) {
    _isPreviewVideo = previewVideo;
    return _instance;
  }

  ///是否可播放音频
  MediaResourceSelector enablePreviewAudio({bool enablePreviewAudio = true}) {
    _mEnablePreviewAudio = enablePreviewAudio;
    return _instance;
  }

  ///是否显示拍照按钮
  MediaResourceSelector isCamera({bool iscamera = true}) {
    _mIsCamera = iscamera;
    return _instance;
  }

  //图片列表点击 缩放效果 默认true
  MediaResourceSelector isZoomAnim({bool iszoomAnimal = true}) {
    _mIsZoomAnim = iszoomAnimal;
    return _instance;
  }

  ///是否裁剪
  MediaResourceSelector enableCrop({bool enablecrop = false}) {
    _mEnableCrop = enablecrop;
    return _instance;
  }

  /// 是否压缩
  MediaResourceSelector compress({bool compress = true}) {
    _mCompress = compress;
    return _instance;
  }

  ///
  MediaResourceSelector synOrAsy({bool synOrAsy = true}) {
    _msynOrAsy = synOrAsy;
    return _instance;
  }

  ///加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度
  MediaResourceSelector glideOverride({int width = 100, int height = 100}) {
    _mWidth = width;
    _mHeight = height;
    return _instance;
  }

  ///是否开启点击声音
  MediaResourceSelector openClickSound({open = false}) {
    _mOpenSound = open;
    return _instance;
  }

  Future<ImageBeanEntity> getPhotoAlbumToNative() async {
    Map<String, dynamic> map = {
      "mPictureMimeType": _mPictureMimeType,
      "mMxSelectNum": _mMxSelectNum,
      "mInSelectNum": _mInSelectNum,
      "sPanCount": _sPanCount,
      "mSelectionMode": _mSelectionMode,
      "isPreviewImage": _isPreviewImage,
      "isPreviewVideo": _isPreviewVideo,
      "mEnablePreviewAudio": _mEnablePreviewAudio,
      "mIsCamera": _mIsCamera,
      "mIsZoomAnim": _mIsZoomAnim,
      "mOpenSound": _mOpenSound,
      "mWidth": _mWidth,
      "mHeight": _mHeight,
      "msynOrAsy": _msynOrAsy,
      "mCompress": _mCompress,
      "mEnableCrop": _mEnableCrop
    };

    if (Platform.isAndroid) {
      String resultJson =
          await FlupickMediaresource.flupick_mediaresource_channel.invokeMethod('openPhotoAlbum', map);
      Map<String, dynamic> mapJson = json.decode(resultJson);
      ImageBeanEntity imageBeanEntity = ImageBeanEntity().fromJson(mapJson);
      return imageBeanEntity;
    } else {
      //ios端选择图片的处理
      List list = await FlupickMediaresource.flupick_mediaresource_channel.invokeMethod('get_mediaResource', map);

      //拿到结果后的处理
      ImageBeanEntity imageBeanEntity = ImageBeanEntity();
      List<ImageBeanImageList> imageList = new List<ImageBeanImageList>();
      for (int index = 0; index < list.length; index++) {
        String filePath = list[index]['path'];
        String type = list[index]['type'];
        List<String> allName = filePath.split("\/");
        String fileName = allName[allName.length - 1];

        ImageBeanImageList imageBeanImageList = new ImageBeanImageList();
        imageBeanImageList.path = filePath;
        // imageBeanImageList.name = fileName;
        imageBeanImageList.type = type;
        imageList.add(imageBeanImageList);
      }

      imageBeanEntity.imageList = imageList;
      return imageBeanEntity;
    }
  }

  static String getAssetType(MediaResourceMimeType type) {
    switch (type) {
      case MediaResourceMimeType.video:
        return "assetVideoOnly";
        break;
      case MediaResourceMimeType.image:
        return "assetImageOnly";
        break;
      case MediaResourceMimeType.all:
        return "assetImageAdnVideo";
        break;
      default:
        return "assetImageAdnVideo";
    }
  }
}

package com.willian.flupick_mediaresource;

import android.app.Activity;
import android.app.Application;
import android.content.pm.ActivityInfo;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import com.willian.flupick_mediaresource.config.BaseConfig;
import com.willian.flupick_mediaresource.plugin.FileAndImagePickerDelegate;
import com.willian.flupick_mediaresource.plugin.MyActivityLifecycle;
import com.willian.flupick_mediaresource.view.filepicker.models.sort.SortingTypes;
import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;

import java.util.ArrayList;
import droidninja.filepicker.FilePickerBuilder;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import androidx.annotation.NonNull;

import java.util.ArrayList;

import droidninja.filepicker.FilePickerBuilder;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterpluginwangfeiPlugin
 */
public class FlupickMediaresourcePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private Activity activity;
  private Application application;
  private FileAndImagePickerDelegate delegate;
  private FlutterPluginBinding pluginBinding;
  private MyActivityLifecycle observer;
  private Lifecycle lifecycle;
  private ActivityPluginBinding activityBinding;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = flutterPluginBinding;

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flupick_mediaresource");
    channel.setMethodCallHandler(this);
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), BaseConfig.CHANNEL);
    channel.setMethodCallHandler(new FlupickMediaresourcePlugin());
    if (registrar.activity() == null) {
      return;
    }
    Activity activity = registrar.activity();
    Application application = null;
    if (registrar.context() != null) {
      application = (Application) (registrar.context().getApplicationContext());
    }
    FlupickMediaresourcePlugin plugin = new FlupickMediaresourcePlugin();
    plugin.setup(registrar.messenger(), application, activity, registrar, null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("openFile")) {
      //Map<String, dynamic> map = {"maxCount":filePickerMaxCount,"activityTitle":filePickerActivityTitle,"zip":zips};
      int openImageMessage = call.argument("maxCount");
      String title = call.argument("activityTitle");
      ArrayList zips = call.argument("zip");
      String[] zipss = (String[]) zips.toArray(new String[0]);
      String[] pdfs = {".pdf"};
      FilePickerBuilder.getInstance()
              .setMaxCount(openImageMessage)
              .setActivityTheme(R.style.FilePickerTheme)
              .setActivityTitle(title)
              .addFileSupport("ZIP", zipss)
              .addFileSupport("PDF", pdfs)
              .enableImagePicker(true)
              .enableVideoPicker(true)
              .enableDocSupport(true)
              .enableSelectAll(true)
              .sortDocumentsBy(SortingTypes.name)
              .withOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED)
              .pickFile(activity);
      delegate.setResult(result);
    } else if (call.method.equals("openPhotoAlbum")) {
      int mPictureMimeType = call.argument("mPictureMimeType");
      int mMxSelectNum = call.argument("mMxSelectNum");
      int mInSelectNum = call.argument("mInSelectNum");
      int sPanCount = call.argument("sPanCount");
      int mSelectionMode = call.argument("mSelectionMode");
      boolean isPreviewImage = call.argument("isPreviewImage");
      boolean isPreviewVideo = call.argument("isPreviewVideo");
      boolean mEnablePreviewAudio = call.argument("mEnablePreviewAudio");
      boolean mIsCamera = call.argument("mIsCamera");
      boolean mIsZoomAnim = call.argument("mIsZoomAnim");
      boolean mOpenSound = call.argument("mOpenSound");
      int mWidth = call.argument("mWidth");
      int mHeight = call.argument("mHeight");
      boolean msynOrAsy = call.argument("msynOrAsy");
      boolean mCompress = call.argument("mCompress");
      boolean mEnableCrop = call.argument("mEnableCrop");
      PictureSelector.create(activity)
              .openGallery(mPictureMimeType)// 全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
              .theme(R.style.picture_default_style)// 主题样式设置 具体参考 values/styles   用法：R.style.picture.white.style
              .maxSelectNum(mMxSelectNum)//TODO 王飞 最大图片选择数量需要减去已近又得哦。
              .minSelectNum(mInSelectNum)// 最小选择数量
              .imageSpanCount(sPanCount)// 每行显示个数
              .selectionMode(PictureConfig.MULTIPLE)// 多选 or 单选PictureConfig.MULTIPLE  多选 PictureConfig.SINGLE)//  单选
              .previewImage(isPreviewImage)// 是否可预览图片
              .previewVideo(isPreviewVideo)// 是否可预览视频
              .enablePreviewAudio(mEnablePreviewAudio) // 是否可播放音频
              .isCamera(mIsCamera)// 是否显示拍照按钮
              .isZoomAnim(true)// 图片列表点击 缩放效果 默认true
              .enableCrop(false)// 是否裁剪
              .compress(true)// 是否压缩
              .synOrAsy(true)//同步true或异步false 压缩 默认同步
              .glideOverride(100, 100)// glide 加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度
              .openClickSound(mOpenSound)// 是否开启点击声音
              .forResult(PictureConfig.CHOOSE_REQUEST);//结果回调onActivityResult code
      delegate.setResult(result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    pluginBinding = null;
  }

  public void setup(final BinaryMessenger messenger, final Application application, final Activity activity, final PluginRegistry.Registrar registrar, final ActivityPluginBinding activityBinding) {
    this.activity = activity;
    this.application = application;
    this.delegate = new FileAndImagePickerDelegate(activity);
    channel = new MethodChannel(messenger, "plugins.flutter.io/file_image_picker");
    channel.setMethodCallHandler(this);
    observer = new MyActivityLifecycle(activity);
    Log.e("wangfei==", "002");
    if (registrar != null) {
      // V1 embedding setup for activity listeners.
      application.registerActivityLifecycleCallbacks(observer);
      registrar.addActivityResultListener(delegate);
      registrar.addRequestPermissionsResultListener(delegate);
    } else {
      // V2 embedding setup for activity listeners.
      if (activityBinding != null) {
        Log.e("wangfei==", "002");
        activityBinding.addActivityResultListener(delegate);
        activityBinding.addRequestPermissionsResultListener(delegate);
      }
    }


  }

  private void tearDown() {
    activityBinding.removeActivityResultListener(delegate);
    activityBinding.removeRequestPermissionsResultListener(delegate);
    activityBinding = null;
    lifecycle.removeObserver(observer);
    lifecycle = null;
    delegate = null;
    channel.setMethodCallHandler(null);
    channel = null;
    application.unregisterActivityLifecycleCallbacks(observer);
    application = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    Log.e("wangfei==", "001");
    activityBinding = binding;
    setup(pluginBinding.getBinaryMessenger(), (Application) pluginBinding.getApplicationContext(), activityBinding.getActivity(), null, activityBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();

  }
}


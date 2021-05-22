

#ifndef YDConfig_h
#define YDConfig_h

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t  %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

#define SafeAreaTopHeight (IPhoneXLater ? 88 : 64)

// 屏幕宽/高
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define STATUSHEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

#define Home_Seleted_Item_W 60
#define DefaultMargin       10

//首页headview的高度
#define kHeaderHeight  40.0f

#define ScreenMaxLength (MAX(ScreenHeight, ScreenWidth))
#define IPhone (UI_USER_INTERFACE_IDIOM()         == UIUserInterfaceIdiomPhone)
#define IPhoneXLater (IPhone && ScreenMaxLength > 812.0)
#define rgba(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]

#import "UIImage+Resize.h"
#import "UIView+SLExtension.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+AlivcHelper.h"

#import "AliyunAlbumModel.h"
#import "AliyunPhotoLibraryManager.h"

#define PTX_VIDEO_MAX_DURATION 15.0f //GZSelectVideoGoView：视频最大时长。

#endif /* YDConfig_h */


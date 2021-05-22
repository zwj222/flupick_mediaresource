//
//  GZSelectVideoView.h
//  CommunityDemo
//
//  Created by soco on 2021/4/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GZSelectVideoView : UIView

@property (nonatomic, copy) void(^popBlock)(void);
@property (nonatomic, copy) void(^takePicBlock)(UIImage *image);
@property (nonatomic, copy) void(^takeVideoBlock)(NSURL *videoUrl);

+ (instancetype)createGZSelectVideoView;

@end

NS_ASSUME_NONNULL_END

//
//  UIView+SLExtension.h
//
//  Created by Alin on 15/12/31.
//  Copyright © 2015年 Alin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SLExtension)
/** X */
@property (nonatomic, assign) CGFloat x;

/** Y */
@property (nonatomic, assign) CGFloat y;

/** Width */
@property (nonatomic, assign) CGFloat width;

/** Height */
@property (nonatomic, assign) CGFloat height;

/** size */
@property (nonatomic, assign) CGSize size;

/** centerX */
@property (nonatomic, assign) CGFloat centerX;

/** centerY */
@property (nonatomic, assign) CGFloat centerY;

/** tag */
@property (nonatomic, copy) NSString *tagStr;


@property (nonatomic, assign) CGPoint origin;

@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat right;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat bottom;

@property (readonly) UIViewController *viewController;

- (BOOL)isShowingOnKeyWindow;
@end

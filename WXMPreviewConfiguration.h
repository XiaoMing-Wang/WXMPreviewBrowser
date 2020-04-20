//
//  WXMPreviewConfiguration.h
//  Multi-project-coordination
//
//  Created by wq on 2020/1/11.
//  Copyright © 2020 wxm. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef WXMPreviewConfiguration_h
#define WXMPreviewConfiguration_h

/** 隐藏当前控件 */
#define WXMHideCurrentContent NO
#define WXMPlaceholderColor kRGBColor(245, 245, 245)

/** 屏幕宽高 */
#define kSWidth [UIScreen mainScreen].bounds.size.width
#define kSHeight [UIScreen mainScreen].bounds.size.height
#define kCenter CGPointMake(kSWidth / 2.0, kSHeight / 2.0)
#define KWindow [[[UIApplication sharedApplication] delegate] window]

/** 导航栏高度 安全高度 */
#define kNBarHeight ((kIPhoneX) ? 88.0f : 64.0f)

/** iphoneX */
#define kIPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);\
})

/** 颜色(RGB) */
#define kRGBColor(r, g, b) \
[UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]

/** 照片类型 */
typedef NS_ENUM(NSUInteger, WXMPreviewType) {

    /** 图片 */
    WXMPreviewTypeTypeGraphic = 0,

    /** GIF */
    WXMPreviewTypeTypeGIF,

    /** 视频 */
    WXMPreviewTypeTypeVideo,

};

@class WXMPreviewBrowser;
@protocol WXMPreviewDelegate <NSObject>
@optional

/** 获取当前imageview */
- (UIImageView *)currentDisplayWithIndex:(NSInteger)index;

@end

#endif /* WXMPreviewConfiguration_h */

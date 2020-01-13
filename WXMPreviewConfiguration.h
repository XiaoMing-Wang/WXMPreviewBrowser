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

/** 获取方式 */
typedef NS_ENUM(NSUInteger, WXMPreviewAccessType) {

    /** 1通过父视图获取(本地) */
    WXMPreviewAccessTypeSupView = 0,

    /** 2通过数组获取(本地+网络) */
    WXMPreviewAccessTypeList,

    /** 3网络 */
    WXMPreviewAccessTypeDynamic,
};

/** 1直接预览原图 */
/** 2先缩略图 后原图 */
/** 3无缩略图 直接原图 */
@class WXMPreviewBrowser;
@protocol WXMPreviewDelegate <NSObject>
@optional

/** 获取当前imageview */
- (UIImageView *)currentDisplayWithIndex:(NSInteger)index;

/** 返回当前大图链接 返回nil不会更新 */
- (NSString *)currentOriginalUrlWithIndex:(NSInteger)index;

@end

#endif /* WXMPreviewConfiguration_h */

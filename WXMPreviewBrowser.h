//
//  WXMPreviewControlView.h
//  TianMiMi
//
//  Created by sdjim on 2019/12/4.
//  Copyright © 2019 sdjgroup. All rights reserved.
//
/** 图片预览控件 */
#import <UIKit/UIKit.h>
#import "WXMPreviewConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMPreviewBrowser : UIView

/** 下层界面 */
@property (nonatomic, weak) UIView *containerView;

/** 代理 */
@property (nonatomic, weak) id<WXMPreviewDelegate> delegate;

/** 当前图片下标 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 图片总个数 */
@property (nonatomic, assign) NSInteger imageCount;

/** 预览图片总数 */
@property (nonatomic, assign) NSArray<UIImage *> *imageArray;

/** 显示的控制器 */
@property (nonatomic, weak) UIViewController *displayControlle;

/** 资源获取方式 默认从父视图获取 */
@property (nonatomic, assign) WXMPreviewAccessType accessType;

/** 显示图形浏览器 */
- (void)showPreviewBrowser;

@end

NS_ASSUME_NONNULL_END

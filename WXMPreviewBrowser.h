//
//  WXMPreviewControlView.h
//  TianMiMi
//
//  Created by wxm on 2019/12/4.
//  Copyright © 2019 wxm. All rights reserved.
//
/** 图片预览控件 */
#import <UIKit/UIKit.h>
#import "WXMPreviewConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMPreviewBrowser : UIView


@property (nonatomic, assign) BOOL haveNavigationBar;

/** 下层界面 */
@property (nonatomic, weak) UIView *containerView;

/** 代理 */
@property (nonatomic, weak) id<WXMPreviewDelegate> delegate;

/** 显示的tag值 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 图片总个数 imageCount和imageArray 设置一个即可 都设置以imageArray为准 */
@property (nonatomic, assign) NSInteger imageCount;

/** 请求的url数组 */
@property (nonatomic, assign) NSArray<NSString *> *imageArray;

/** 显示的控制器 */
@property (nonatomic, weak) UIViewController *displayControlle;

/** 显示图形浏览器 */
- (void)showPreviewBrowser;

@end

NS_ASSUME_NONNULL_END

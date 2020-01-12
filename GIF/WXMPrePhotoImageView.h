//
//  WXMPrePhotoImageView.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//
/** 先暂停再设置currentFrameIndex最后startAnimating */
#import <UIKit/UIKit.h>

@class WXMPrePhotoGIFImage;
@interface WXMPrePhotoImageView : UIImageView

@property (nonatomic, assign) BOOL gifAnimating;

/** 当前播放到的张数 */
@property (nonatomic) NSUInteger currentFrameIndex;

/** runLoopMode */
@property (nonatomic, copy) NSString *runLoopMode;

/** 开启动画 */
- (void)startAnimating;

/** 停止动画 */
- (void)stopAnimating;

/** 设置 */
- (void)setAnimatedImage:(WXMPrePhotoGIFImage *)animatedImage;

@end

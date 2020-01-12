//
//  WXMPreviewBrowserCell.h
//  TianMiMi
//
//  Created by wq on 2019/12/7.
//  Copyright © 2019 sdjgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPreviewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class WXMPhotoImageView;
@interface WXMPreviewBrowserCell : UICollectionViewCell

/** 整个视图的黑色底板 */
@property (nonatomic, strong) UIView *blackBoard;

/** 显示model */
@property (nonatomic, strong) WXMPreviewModel *previewModel;

/** 单击 */
@property (nonatomic, strong) void (^singleTouch)(NSInteger index);
@property (nonatomic, strong) void (^dropDownBegin)(NSInteger index);
@property (nonatomic, strong) void (^dropDownEnd)(NSInteger, BOOL, CGRect);

/** 还原zoom */
- (void)originalAppearance;

/** 加载原生图片 */
- (void)loadOriginalImage;

@end

NS_ASSUME_NONNULL_END

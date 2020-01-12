//
//  WXMPreviewModel.h
//  Multi-project-coordination
//
//  Created by wq on 2020/1/11.
//  Copyright © 2020 wxm. All rights reserved.

#import <Foundation/Foundation.h>
#import "WXMPreviewConfiguration.h"

NS_ASSUME_NONNULL_BEGIN


@interface WXMPreviewModel : NSObject

/** 资源类型 */
@property (nonatomic, assign) WXMPreviewType previewType;

/** 标识 */
@property (nonatomic, assign) NSInteger index;

/** 原始图链接 */
@property (nonatomic, copy) NSString *originalUrl;

/** 视频保存路径 */
@property (strong, nonatomic) NSString *filePath;

/** 缩略图 */
@property (nonatomic, strong) UIImage *thumbnailImage;

/** 原始图 */
@property (nonatomic, strong) UIImage *originalImage;

/** 长宽比 */
@property (nonatomic, assign) CGFloat aspectRatio;

/** 是否是在完成原始图 */
@property (nonatomic, assign) BOOL download;

/** 是否显示高清图 */
@property (nonatomic, assign) BOOL displayOriginal;

@end

NS_ASSUME_NONNULL_END

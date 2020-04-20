//
//  WXMPreviewDirectionPan.h
//  Multi-project-coordination
//
//  Created by wq on 2020/1/11.
//  Copyright © 2020 wxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    
    /** 竖向 */
    WXMPreviewRecognizerVertical,
    
    /** 横向 */
    WXMPreviewRecognizerHorizontal,
    
    /** 只支持下 */
    WXMPreviewRecognizerBottom
    
    
} WXMPreviewRecognizerDirection;

@interface WXMPreviewDirectionPan : UIPanGestureRecognizer {
@public
    BOOL _drag;
    int _moveX;
    int _moveY;
    WXMPreviewRecognizerDirection _direction;
}
@property (nonatomic, assign) WXMPreviewRecognizerDirection direction;
@end

NS_ASSUME_NONNULL_END

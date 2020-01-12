//
//  WXMPreviewDirectionPan.m
//  Multi-project-coordination
//
//  Created by wq on 2020/1/11.
//  Copyright © 2020 wxm. All rights reserved.
//

#import "WXMPreviewDirectionPan.h"

int const static kwxmDirectionPanThreshold = 5;
@implementation WXMPreviewDirectionPan
@synthesize direction = _direction;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    
    if (!_drag) {
        if (abs(_moveX) > kwxmDirectionPanThreshold) {
            if (_direction == WXMPreviewRecognizerVertical ||
                _direction == WXMPreviewRecognizerBottom) {
                self.state = UIGestureRecognizerStateFailed;
            } else {
                _drag = YES;
            }
        } else if (abs(_moveY) > kwxmDirectionPanThreshold) {
            if (_direction == WXMPreviewRecognizerHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            } else if (_direction == WXMPreviewRecognizerBottom) {
                if (_moveY > 0) {
                    self.state = UIGestureRecognizerStateFailed;
                } else {
                    _drag = YES;
                }
            } else {
                _drag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}



@end

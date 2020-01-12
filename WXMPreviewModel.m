//
//  WXMPreviewModel.m
//  Multi-project-coordination
//
//  Created by wq on 2020/1/11.
//  Copyright © 2020 wxm. All rights reserved.
//

#import "WXMPreviewModel.h"

@implementation WXMPreviewModel

- (BOOL)download {
    if (self.originalImage) return YES;
    if (!self.originalUrl) return YES;
    return NO;
}

@end

////
////  WXMPreviewBrowserCell.m
////  TianMiMi
////
////  Created by wq on 2019/12/7.
////  Copyright © 2019 wxm. All rights reserved.
////

#import "SDWebImageManager.h"
#import "WXMDownloadManager.h"
#import "SDWebImageDownloader.h"
#import "UIImageView+WebCache.h"
#import "WXMPrePhotoImageView.h"
#import "WXMPreviewBrowserCell.h"
#import "WXMPreviewDirectionPan.h"
#import "WXMPrePhotoGIFImage.h"
#import "WXMDownloadProgressBar.h"
#import "WXMPreviewConfiguration.h"
#import <AVFoundation/AVFoundation.h>

@interface WXMPreviewBrowserCell () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WXMPrePhotoImageView *imageView;
@property (nonatomic, strong) WXMPreviewDirectionPan *recognizer;
@property (nonatomic, strong) WXMDownloadProgressBar *progressBar;

/** 正在播放 */
@property (strong, nonatomic) NSString *playingUrl;

/** 播放器 */
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *item;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

/** 距离原点的比例 */
@property (nonatomic, assign) CGFloat wxm_x;
@property (nonatomic, assign) CGFloat wxm_y;
@property (nonatomic, assign) CGFloat wxm_zoomScale;
@property (nonatomic, assign) CGPoint wxm_lastPoint;

@property (nonatomic, assign) BOOL requestError;

@end

@implementation WXMPreviewBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initializationInterface];
    return self;
}

/** 初始化界面 */
- (void)initializationInterface {
    CGFloat w = kSWidth;
    CGFloat h = kSHeight;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.scrollView.delegate = self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.layer.masksToBounds = NO;
    
    self.imageView = [[WXMPrePhotoImageView alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.userInteractionEnabled = NO;
    
    self.progressBar = [[WXMDownloadProgressBar alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.progressBar.center = CGPointMake(w / 2, h / 2);
    self.progressBar.hidden = YES;
    
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.scrollView addSubview:self.progressBar];
    [self.scrollView setMinimumZoomScale:1.0];
    [self.scrollView setMaximumZoomScale:2.5f];
    [self addTapGestureRecognizer];
}

- (void)setPreviewModel:(WXMPreviewModel *)previewModel {
    _previewModel = previewModel;
    BOOL isGraphic= (previewModel.previewType != WXMPreviewTypeTypeVideo);
    if (self.previewModel.originalImage && isGraphic) {
        
        self.imageView.image = previewModel.originalImage;
        self.imageView.backgroundColor = [UIColor clearColor];
        
    } else if (previewModel.thumbnailImage && isGraphic) {
        
        [self judgeCacleExsit];
        self.imageView.image = previewModel.thumbnailImage;
        self.imageView.backgroundColor = [UIColor clearColor];
        
    } else if (isGraphic) {
        
        self.imageView.image = nil;
        self.imageView.backgroundColor = WXMPlaceholderColor;
        [self judgeCacleExsit];
        
    } else if (isGraphic == NO) {
        
        self.imageView.image = previewModel.thumbnailImage;
        if (!previewModel.thumbnailImage)  self.imageView.backgroundColor = WXMPlaceholderColor;
    }
    
    [self setLocationWithAspectRatio:previewModel.aspectRatio];
    if (self.previewModel.thumbnailImage || self.previewModel.originalImage) {
        self.imageView.backgroundColor = [UIColor clearColor];
    }
}

/** 设置image位置 */
- (void)setLocationWithAspectRatio:(CGFloat)proportion {
    CGFloat cw = self.scrollView.frame.size.width;
    CGFloat ch = self.scrollView.frame.size.height;
    self.imageView.frame = CGRectMake(0, 0, kSWidth, kSWidth * proportion);
    self.imageView.center = CGPointMake(cw / 2, ch / 2);
    
    self.scrollView.maximumZoomScale = 2.5;
    if (self.imageView.frame.size.height * self.scrollView.maximumZoomScale < kSHeight) {
        CGFloat maxZoomScale = kSHeight / self.imageView.frame.size.height;
        self.scrollView.maximumZoomScale = maxZoomScale;
    }
    
    if (proportion == (kSHeight / kSWidth * 1.0)) {
        self.imageView.backgroundColor = [UIColor blackColor];
    }
}

/** 加载原生图片 */
- (void)loadOriginalImage {
    BOOL isGraphic = (self.previewModel.previewType != WXMPreviewTypeTypeVideo);
    if (self.judgeCacleExsit == NO && isGraphic) {
        
        [self downloadImage];
    } else if (isGraphic == NO) {
        
        NSLog(@"下载视频");
        [self downloadVideo];
    }
}

/** 判断缓存是否存在 */
- (BOOL)judgeCacleExsit {
    if (!self.previewModel.originalUrl) return YES;
    if (self.previewModel.displayOriginal) return YES;
    if (self.imageView.image == self.previewModel.originalImage &&
        self.imageView.image) return YES;
    
    NSURL *url = [NSURL URLWithString:self.previewModel.originalUrl];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    SDImageCache* cache = [SDImageCache sharedImageCache];
    
    if (self.previewModel.previewType == WXMPreviewTypeTypeGraphic) {
       
        UIImage *image = [cache imageFromCacheForKey:[manager cacheKeyForURL:url]];
        if (image) {
            self.imageView.image = image;
            self.previewModel.originalImage = image;
            self.previewModel.displayOriginal = YES;
            self.imageView.backgroundColor = [UIColor clearColor];
            CGFloat aspectRatio = image.size.height / image.size.width;
            if (!isnan(aspectRatio)) {
                self.previewModel.aspectRatio = aspectRatio;
                [self setLocationWithAspectRatio:aspectRatio];
            }
            return YES;
        }
     
        
    } else if (self.previewModel.previewType == WXMPreviewTypeTypeGIF) {
        
        NSData *data = [cache diskImageDataForKey:[manager cacheKeyForURL:url]];
        if (data) {
            self.imageView.backgroundColor = [UIColor clearColor];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                WXMPrePhotoGIFImage *image =
                (WXMPrePhotoGIFImage *)[WXMPrePhotoGIFImage imageWithData:data];
                
                UIImage *first = [image getFrameWithIndex:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                    self.previewModel.originalImage = image;
                    self.previewModel.displayOriginal = YES;
                    if (first) {
                        CGFloat aspec = first.size.height / first.size.width;
                        if (!isnan(aspec)) self.previewModel.aspectRatio = aspec;
                        if (!isnan(aspec)) [self setLocationWithAspectRatio:aspec];
                    }
                });
            });
            return YES;
        }
    }
    
    return NO;
}

/** 下载图片  */
- (void)downloadImage {
    if (!self.previewModel.originalUrl) return;

    NSLog(@"下载图片");
    __weak __typeof(self) self_weak = self;
    NSURL *url = [NSURL URLWithString:self.previewModel.originalUrl];
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    [manager downloadImageWithURL:url options:0 progress:^(NSInteger size, NSInteger exSize, NSURL *targetURL) {
        
        if (size > 0 && exSize > 0) {
            CGFloat progree = size / (exSize * 1.0);
            self_weak.progressBar.progress = progree;
        }
              
    }  completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        if (image && !error) {
            NSLog(@"下载完成");
            self_weak.imageView.image = image;
            self_weak.previewModel.originalImage = image;
            self_weak.imageView.backgroundColor = [UIColor clearColor];
            if (data && self_weak.previewModel.previewType == WXMPreviewTypeTypeGIF) {
                self_weak.previewModel.originalImage = [WXMPrePhotoGIFImage imageWithData:data];
                self_weak.imageView.image = self_weak.previewModel.originalImage;
                CGFloat aspec = image.size.height / image.size.width;
                if (!isnan(aspec)) {
                    self_weak.previewModel.aspectRatio = aspec;
                    [self_weak setLocationWithAspectRatio:aspec];
                }
            }
            SDImageCache* cache = [SDImageCache sharedImageCache];
            [cache storeImageDataToDisk:data forKey:url.absoluteString];
        }
                
    }];
    
}

/** 下载视频 */
- (void)downloadVideo {
    if (!self.previewModel.originalUrl) return;
    
    __weak __typeof(self) self_weak = self;
    NSString *filePath = self.previewModel.originalUrl;
    WXMDownloadManager *manager = [WXMDownloadManager sharedInstance];
    [manager downloadFromURL:filePath progress:^(CGFloat downloadProgress) {

        [self_weak.scrollView bringSubviewToFront:self_weak.progressBar];
        self_weak.progressBar.progress = downloadProgress;
        self_weak.playerLayer.hidden = YES;
        
    } complement:^(NSString *filePath, NSError *error) {
        
        /** 重新下载一遍 */
        if (error && !self_weak.requestError) {
            [self_weak downloadVideo];
            self_weak.requestError = YES;
            return;
        }
        
        self_weak.imageView.image = nil;
        self_weak.previewModel.filePath = filePath.copy;
        NSURL *url = [NSURL fileURLWithPath:filePath];
        UIImage *image = [self_weak thumbnailImageForVideo:url];
        if (image) {
            if (!self_weak.previewModel.thumbnailImage) {
                self_weak.previewModel.thumbnailImage = image;
                self_weak.imageView.image = image;
            }
            
            CGFloat aspec = image.size.height / image.size.width * 1.0;
            if (!isnan(aspec)) self_weak.previewModel.aspectRatio = aspec;
            if (!isnan(aspec)) [self_weak setLocationWithAspectRatio:aspec];
        }
        [self_weak playVideos];
    }];
}

/** 每次播放重新创建 更换item有BUG */
- (void)playVideos {
    if (!self.previewModel.filePath) return;
    if ([self.previewModel.filePath isEqualToString:self.playingUrl]) return;
    
    [self releaseControls];
    NSString *filePath = self.previewModel.filePath;
    self.playingUrl = filePath.copy;
    self.item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
    self.player = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.imageView.bounds;
    [self.imageView.layer insertSublayer:self.playerLayer atIndex:0];
    [self.player play];
}

/** 添加手势 */
- (void)addTapGestureRecognizer {
    SEL selTap = @selector(respondsToTapSingle:);
    UITapGestureRecognizer *tapSingle = nil;
    tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:selTap];
    tapSingle.numberOfTapsRequired = 1;
    
    SEL doubleTap = @selector(respondsToTapDouble:);
    UITapGestureRecognizer *tapDouble = nil;
    tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:doubleTap];
    tapDouble.numberOfTapsRequired = 2;
    
    SEL handle = @selector(handlePan:);
    _recognizer = [[WXMPreviewDirectionPan alloc] initWithTarget:self action:handle];
    _recognizer->_direction = WXMPreviewRecognizerBottom;
    _recognizer.maximumNumberOfTouches = 1;
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    [tapSingle requireGestureRecognizerToFail:_recognizer];
    [tapDouble requireGestureRecognizerToFail:_recognizer];
    
    [_scrollView addGestureRecognizer:tapSingle];
    [_scrollView addGestureRecognizer:tapDouble];
    [_scrollView addGestureRecognizer:_recognizer];
}

/** 单击 */
- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    [self releaseControls];
    if (self.singleTouch) self.singleTouch(self.previewModel.index);
}

/** 双击 */
- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap {
    UIScrollView *scrollView = self.scrollView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

/** 滑动 */
/** 这里采用的判断是 在图片缩小过程中 手指的点始终距离图片的xy顶点是view真实大小(view一直在缩小)的固定比例 */
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    CGPoint center = recognizer.view.center;
    CGPoint translation = [recognizer translationInView:self];  /** 位移 */
    CGFloat wxm_centery = center.y + translation.y;             /** y轴位移 */
    CGFloat recognizer_W = recognizer.view.frame.size.width;
    CGFloat recognizer_H = recognizer.view.frame.size.height;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self];
        self.wxm_x = point.x / recognizer_W;
        self.wxm_y = point.y / recognizer_H;
        self.wxm_lastPoint = recognizer.view.center;
        if (self.dropDownBegin) self.dropDownBegin(self.previewModel.index);
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat displacement = wxm_centery - self.wxm_lastPoint.y;
        CGFloat proportion = 1;
        CGFloat scaleAlpha = 1;
        if (displacement <= 0) proportion = 1;
        else {
            CGFloat maxH = kSHeight * 1.25;
            CGFloat scale = displacement / maxH;
            scaleAlpha = 1 - (displacement / (kSHeight * 0.6));
            proportion = MAX(1 - scale, 0.3);
            if (displacement <= 0) scaleAlpha = 1;
        }
        self.blackBoard.alpha = scaleAlpha;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
        
        CGPoint point_XY = [recognizer locationInView:self];
        CGFloat distance_x = recognizer_W * _wxm_x;
        CGFloat distance_y = recognizer_H * _wxm_y;
        CGRect rect = recognizer.view.frame;
        rect.origin.x = point_XY.x - distance_x;
        rect.origin.y = point_XY.y - distance_y;
        recognizer.view.frame = rect;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];  /** 速度 */
        BOOL cancle = (velocity.y < 5 || self.blackBoard.alpha >= 1);
        if (cancle) {
            
            self.scrollView.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.35 animations:^{
                recognizer.view.transform = CGAffineTransformIdentity;
                recognizer.view.center = self.wxm_lastPoint;
                self.blackBoard.alpha = 1;
            } completion:^(BOOL finished) {
                if (self.dropDownEnd) self.dropDownEnd(self.previewModel.index, YES, CGRectZero);
            }];
            
        } else {
            [self releaseControls];
            self.scrollView.userInteractionEnabled = NO;
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            CGRect rect = [self.imageView convertRect:self.imageView.bounds toView:window];
            if (self.dropDownEnd) self.dropDownEnd(self.previewModel.index,NO,rect);
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect imageViewFrame = self.imageView.frame;
    CGFloat width = imageViewFrame.size.width;
    CGFloat height = imageViewFrame.size.height;
    CGFloat sHeight = scrollView.bounds.size.height;
    CGFloat sWidth = scrollView.bounds.size.width;
    if (height > sHeight) imageViewFrame.origin.y = 0;
    else imageViewFrame.origin.y = (sHeight - height) / 2.0;
    
    if (width > sWidth) imageViewFrame.origin.x = 0;
    else imageViewFrame.origin.x = (sWidth - width) / 2.0;
    self.imageView.frame = imageViewFrame;
}

/** 还原 */
- (void)originalAppearance {
    [self releaseControls];
    [self.scrollView setZoomScale:1.0 animated:NO];
    if (self.previewModel.previewType == WXMPreviewTypeTypeVideo) {
        self.imageView.image = self.previewModel.thumbnailImage;
    }
}

- (void)releaseControls {
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    self.item = nil;
    self.player = nil;
    self.playerLayer = nil;
    self.playingUrl = nil;
}

/// 同步获取本地视频第一帧
/// @param videoURL url
- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end

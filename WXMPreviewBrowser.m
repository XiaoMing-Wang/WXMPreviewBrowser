////
////  WXMPreviewControlView.m
////  TianMiMi
////
////  Created by sdjim on 2019/12/4.
////  Copyright © 2019 sdjgroup. All rights reserved.
////

#import "WXMPreviewBrowser.h"
#import "WXMPreviewBrowserCell.h"
#import "WXMPrePhotoGIFImage.h"
#import "WXMPrePhotoImageView.h"

@interface WXMPreviewBrowser () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UIView *blackBoard;
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation WXMPreviewBrowser

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kSWidth, kSHeight);
        self.backgroundColor = [UIColor clearColor];
        [self initializationInterface];
    }
    return self;
}

- (void)initializationInterface {
    self.blackBoard = [[UIView alloc] initWithFrame:self.bounds];
    self.blackBoard.backgroundColor = [UIColor blackColor];
    self.blackBoard.alpha = 0;

    CGRect rect = CGRectMake(30, kSHeight - 50, kSWidth - 60, 25);
    self.pageController = [[UIPageControl alloc] initWithFrame:rect];

    self.dataSource = @[].mutableCopy;
    [self addSubview:self.blackBoard];
    [self addSubview:self.collectionView];
    [self addSubview:self.pageController];
}

/** 显示 */
- (void)showPreviewBrowser {
    UIImageView *displayIV = self.currentlyDisplay;
    if (!displayIV || ![displayIV isKindOfClass:UIImageView.class]) return;
    
    displayIV.alpha = !WXMHideCurrentContent;
    self.collectionView.alpha = 0;
    [self createPreviewModelDataSource];
        
    /** 在window中位置 */
    CGRect disRect = [self currentlyDisplayRect:displayIV];
    NSInteger index = MAX(self.currentIndex - 1, 0);
        
    /** 当前model */
    WXMPreviewModel *previewModel = [self.dataSource objectAtIndex:index];
    CGFloat disRatio = previewModel.aspectRatio;
    UIImage *displayImage = previewModel.originalImage ?: previewModel.thumbnailImage;
        
    /** 动画view */
    WXMPrePhotoImageView *tempView = [self tempImageView:disRect];
    if (displayImage) {
        tempView.backgroundColor = [UIColor clearColor];
        if (previewModel.previewType == WXMPreviewTypeTypeGIF) {
            tempView.image = previewModel.thumbnailImage;
        } else {
            tempView.image = displayImage;
        }
    }
    
    CGFloat height = disRatio * kSWidth;
    CGFloat sx = kSWidth / (displayIV.frame.size.width * 1.0);
    CGFloat sy = height / (displayIV.frame.size.height * 1.0);
    UIViewAnimationOptions option = UIViewAnimationOptionTransitionFlipFromTop;
    [UIView animateWithDuration:0.25 delay:0 options:option animations:^{
        
        self.blackBoard.alpha = 1;
        tempView.transform = CGAffineTransformMakeScale(sx, sy);
        tempView.center = CGPointMake(kSWidth / 2, kSHeight / 2);
        
    } completion:^(BOOL finished) {
        
        NSInteger currentRows = MAX(self.currentIndex - 1, 0);
        NSInteger maxRow = [self.collectionView numberOfItemsInSection:0];
        if (maxRow > currentRows) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRows inSection:0];
            UICollectionViewScrollPosition position = UICollectionViewScrollPositionNone;
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:position
                                                animated:NO];
        }
        tempView.alpha = 0;
        displayIV.alpha = 1;
        self.collectionView.alpha = 1;
        [self scrollViewDidEndDecelerating:self.collectionView];
    }];
    
    [self addSubview:tempView];
    [self.displaySupView addSubview:self];
}

/** 隐藏 */
- (void)hiddenPreviewBrowser:(CGRect)rects {
    WXMPrePhotoImageView *tempView = nil;
    UIImageView *displayIV = self.currentlyDisplay;

    self.collectionView.alpha = 0;
    displayIV.alpha = (!WXMHideCurrentContent);
    CGRect disRect = [self currentlyDisplayRect:displayIV];
    
    /** 当前model */
    NSInteger index = MAX(0, self.currentIndex - 1);
    WXMPreviewModel *previewModel = [self.dataSource objectAtIndex:index];
    CGFloat disRatio = previewModel.aspectRatio;
    UIImage *displayImage = previewModel.originalImage ?: previewModel.thumbnailImage;
    
    if (CGRectEqualToRect(rects, CGRectZero)) {
        CGFloat width = kSWidth;
        CGFloat height = disRatio * kSWidth;
        CGRect bigRect = CGRectMake(0, 0, width, height);
        tempView = [self tempImageView:bigRect];
        tempView.center = kCenter;
    } else {
        tempView = [self tempImageView:rects];
    }

    if (displayImage) tempView.image = displayImage;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:tempView];
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:0.25 delay:0 options:option animations:^{
        tempView.frame = disRect;
        self.blackBoard.alpha = 0;
    } completion:^(BOOL finished) {
        displayIV.alpha = 1;
        [self removeFromSuperview];
    }];
}

/** 获取当前imageview */
- (UIImageView *)currentlyDisplay {
    self.currentIndex = MAX(1, self.currentIndex);
    if ([self.delegate respondsToSelector:@selector(currentDisplayWithIndex:)]) {
        return [self.delegate currentDisplayWithIndex:self.currentIndex];
    } else {
        return [self.containerView viewWithTag:self.currentIndex];
    }
    return nil;
}

/** 获取view在window中的位置 */
- (CGRect)currentlyDisplayRect:(UIView *)display {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    return [display convertRect:display.bounds toView:window];
}

/** temp ImageView */
- (WXMPrePhotoImageView *)tempImageView:(CGRect)rect {
    WXMPrePhotoImageView *tempView = [[WXMPrePhotoImageView alloc] initWithFrame:rect];
    tempView.contentMode = UIViewContentModeScaleToFill;
    tempView.backgroundColor = WXMPlaceholderColor;
    tempView.layer.masksToBounds = YES;
    return tempView;
}

/** 显示的view */
- (UIView *)displaySupView {
    if (self.displayControlle) return self.displayControlle.view;
    return KWindow.rootViewController.view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (WXMPreviewBrowserCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)index {
    
    WXMPreviewBrowserCell *cell = nil;
    UICollectionView *cv = collectionView;
    cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:index];
    cell.previewModel = [self.dataSource objectAtIndex:index.row];
    cell.blackBoard = self.blackBoard;
    cell.singleTouch = self.singleTouchs;
    cell.dropDownBegin = self.dropDownBegin;
    cell.dropDownEnd  = self.dropDownEnd;
    return cell;
}

/** 创建model数组 */
- (void)createPreviewModelDataSource {
    for (int i = 1; i <= self.imageCount; i++) {
        UIImageView *imageV = nil;
        WXMPreviewModel *previewModel = [[WXMPreviewModel alloc] init];
        
        /** 获取imageview */
        if ([self.delegate respondsToSelector:@selector(currentDisplayWithIndex:)]) {
            imageV = [self.delegate currentDisplayWithIndex:i];
        } else {
            imageV = [self.containerView viewWithTag:i];
        }
        
        
        /** 图片框的比例 有图片用图片 没有用框的比例 */
        if (imageV.image != nil) {
            previewModel.aspectRatio = imageV.image.size.height / imageV.image.size.width * 1.0;
            if (isnan(previewModel.aspectRatio)) {
                previewModel.aspectRatio = imageV.frame.size.height / imageV.frame.size.width * 1.0;
            }
        } else {
            previewModel.aspectRatio = imageV.frame.size.height / imageV.frame.size.width * 1.0;
        }
        previewModel.index = i;
        previewModel.thumbnailImage = imageV.image;
        
        
        /** 获取原始url 没有默认当原始图 */
        NSString *originalUrl = nil;
        if ([self.delegate respondsToSelector:@selector(currentOriginalUrlWithIndex:)]) {
            originalUrl = [self.delegate currentOriginalUrlWithIndex:i];
        }
        previewModel.originalUrl = originalUrl;
        if (!originalUrl) previewModel.originalImage = imageV.image;
                
        
        /** gif */
        if ([originalUrl.pathExtension.lowercaseString isEqualToString:@"gif"] ||
            [imageV.image isKindOfClass:[WXMPrePhotoGIFImage class]]) {
            previewModel.previewType = WXMPreviewTypeTypeGIF;
            if ([imageV.image isKindOfClass:[WXMPrePhotoGIFImage class]]) {
                WXMPrePhotoGIFImage *gifImage = (WXMPrePhotoGIFImage *)imageV.image;
                UIImage *first = [gifImage getFrameWithIndex:0];
                previewModel.originalImage = gifImage;;
                if (first != nil) {
                    previewModel.aspectRatio = first.size.height / first.size.width * 1.0;
                    previewModel.thumbnailImage = first;
                }
            }
        }
        
        /** 视频 */
        if ([originalUrl.pathExtension.lowercaseString isEqualToString:@"mp4"] ||
            [originalUrl.pathExtension.lowercaseString isEqualToString:@"avi"] ||
            [originalUrl.pathExtension.lowercaseString isEqualToString:@"mov"]) {
            previewModel.previewType = WXMPreviewTypeTypeVideo;
        }
        
        [self.dataSource addObject:previewModel];
    }
}

/** 上一个复位 */
- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(originalAppearance)]) {
        [cell performSelector:@selector(originalAppearance)];
    }
}

/** 滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    CGFloat index = offY / scrollView.frame.size.width * 1.0;
    NSInteger integers = floor(index);
    
    NSInteger realIndex = 0;
    if (index - integers > 0.5) {
        realIndex = ceil(index);
    } else {
        realIndex = floor(index);
    }
    self.pageController.currentPage = realIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *index = [NSIndexPath indexPathForRow:_pageController.currentPage inSection:0];
    WXMPreviewBrowserCell *cell = nil;
    cell = (WXMPreviewBrowserCell *)[self.collectionView cellForItemAtIndexPath:index];
    [cell loadOriginalImage];
}

/** 单击回调 */
- (void (^) (NSInteger))singleTouchs {
    return ^(NSInteger index) {
        self.currentIndex = index;
        [self hiddenPreviewBrowser:CGRectZero];
    };
}

/** * 下拉开始  */
- (void (^) (NSInteger))dropDownBegin {
   return ^(NSInteger index) {
       self.pageController.alpha = 0;
       self.currentIndex = index;
       [self.containerView viewWithTag:index].alpha = (!WXMHideCurrentContent);
   };
}

/** * 下拉 */
- (void (^) (NSInteger,BOOL,CGRect))dropDownEnd {
    return ^(NSInteger index, BOOL cancle, CGRect rect) {
        self.currentIndex = index;
        if (cancle) {
            self.pageController.alpha = 1;
            [self.containerView viewWithTag:index].alpha = 1;
        } else [self hiddenPreviewBrowser:rect];
    };
}

- (void)setImageCount:(NSInteger)imageCount {
    _imageCount = imageCount;
    _pageController.numberOfPages = imageCount;
    _pageController.hidden = (imageCount <= 1);
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    _pageController.currentPage = (currentIndex - 1);
}

- (void)setImageArray:(NSArray<UIImage *> *)imageArray {
    _imageArray = imageArray;
    [self setImageCount:imageArray.count];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kSWidth + 20, kSHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, kSWidth + 20, kSHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = NO;
        [_collectionView registerClass:[WXMPreviewBrowserCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (void)dealloc {
    NSLog(@"图形浏览器关闭");
}
@end

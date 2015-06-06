//
//  KDBannerView.m
//  zhonghaijinchao
//
//  Created by Blankwonder on 5/30/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import "KDBannerView.h"

@interface KDBannerView () <UIScrollViewDelegate> 

@end

@implementation KDBannerView {
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    __weak id<KDBannerViewDataSource> _dataSource;
    
    NSTimer *_timer;
}

- (void)_init {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _pageControl = [[UIPageControl alloc] init];
    
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

static const NSInteger kBannerViewTagMask = 10000;
- (void)reloadData {
    NSInteger count = [self.dataSource numberOfViewsInBannerView:self];
    
    _pageControl.numberOfPages = count;
    
    for (UIView *view in _scrollView.subviews) {
        if (view.tag >= kBannerViewTagMask) {
            [view removeFromSuperview];
        }
    }
    
    for (int i = 0; i < count; i++) {
        UIView *view = [self.dataSource bannerView:self viewAtIndex:i];
        [_scrollView addSubview:view];
        view.tag = kBannerViewTagMask + i;
        view.userInteractionEnabled = YES;
        
        for (UIGestureRecognizer *gr in view.gestureRecognizers) {
            [view removeGestureRecognizer:gr];
        }

        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        [view addGestureRecognizer:gr];
    }
    
    [self setNeedsLayout];
}

- (void)setDataSource:(id<KDBannerViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)layoutSubviews {
    _scrollView.frame = self.bounds;
    
    for (UIView *view in _scrollView.subviews) {
        NSInteger index = view.tag - kBannerViewTagMask;
        
        view.frame = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * _pageControl.numberOfPages, self.bounds.size.height);
    
    [_pageControl sizeToFit];
    
    _pageControl.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height - 10);
}

- (void)timer {
    if (_pageControl.numberOfPages == 0) return;
    NSInteger page = _pageControl.currentPage + 1;
    if (page == _pageControl.numberOfPages) page = 0;
    [_scrollView scrollRectToVisible:[_scrollView viewWithTag:page + kBannerViewTagMask].frame
                            animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_timer invalidate];
    _timer = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.autoScrollDuration = _autoScrollDuration;
}

- (void)viewTapped:(UIGestureRecognizer *)gr {
    if ([self.delegate respondsToSelector:@selector(bannerView:didTapView:atIndex:)]) {
        [self.delegate bannerView:self
                       didTapView:gr.view
                          atIndex:gr.view.tag - kBannerViewTagMask];
    }
}

- (void)setAutoScrollDuration:(NSTimeInterval)autoScrollDuration {
    _autoScrollDuration = autoScrollDuration;
    
    [_timer invalidate];
    _timer = nil;
    
    if (autoScrollDuration != 0.0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:autoScrollDuration target:self selector:@selector(timer) userInfo:nil repeats:YES];
    }
}

- (void)dealloc {
    [_timer invalidate];
}

@end

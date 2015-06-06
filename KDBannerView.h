//
//  KDBannerView.h
//  zhonghaijinchao
//
//  Created by Blankwonder on 5/30/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDBannerView;
@protocol KDBannerViewDataSource <NSObject>

- (NSInteger)numberOfViewsInBannerView:(KDBannerView *)bannerView;

- (UIView *)bannerView:(KDBannerView *)bannerView viewAtIndex:(NSInteger)index;

@end

@protocol KDBannerViewDelegate <NSObject>
@optional
- (void)bannerView:(KDBannerView *)bannerView didTapView:(UIView *)view atIndex:(NSInteger)index;

@end

@interface KDBannerView : UIView

@property (weak, nonatomic) IBOutlet id<KDBannerViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<KDBannerViewDelegate> delegate;

@property (nonatomic) NSTimeInterval autoScrollDuration;

- (void)reloadData;

@end

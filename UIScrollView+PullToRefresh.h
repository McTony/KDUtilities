//
//  UIScrollView+PullToRefresh.h
//  Procurify
//
//  Created by Peter Lin on 2014-10-31.
//  Copyright (c) 2014 Procurify. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIScrollView (PullToRefresh)

@property (strong, nonatomic) UIControl *pullToRefreshView;
@property (strong, nonatomic) void (^pullToRefreshBlock)(void);
@property (readonly) BOOL refreshing;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))block;
- (void)addPullToRefreshWithActionHandler:(void (^)(void))block tintColor:(UIColor *)tintColor backgroundColor:(UIColor *)backgroundColor ;

/** Tells the pull-to-refresh view to begin refreshing.
 */
- (void)beginRefreshing;

/** Tells the pull-to-refresh view to end refreshing.
 */
- (void)endRefreshing;

/** Calls the saved pull-to-refresh block.
 */
- (void)triggerPullToRefresh;

@property (strong, nonatomic) UIView *placeHolderView;

- (void)addPlaceHolderView:(id)placeHolderview;
- (void)showPlaceHolder;
- (void)hidePlaceHolder;
- (void)removePlaceHolderView;

@end
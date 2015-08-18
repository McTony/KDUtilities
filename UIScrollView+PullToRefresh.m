//
//  UIScrollView+PullToRefresh.m
//  Procurify
//
//  Created by Peter Lin on 2014-10-31.
//  Copyright (c) 2014 Procurify. All rights reserved.
//

#import "UIScrollView+PullToRefresh.h"
#import <objc/runtime.h>
#import <Availability.h>

static const void *kPullToRefreshViewKey = &kPullToRefreshViewKey;
static const void *kPullToRefreshBlockKey = &kPullToRefreshBlockKey;
static const void *kPlaceHolderViewKey = &kPlaceHolderViewKey;

@implementation UIScrollView (PullToRefresh)

@dynamic pullToRefreshView, pullToRefreshBlock, placeHolderView;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))block {
    [self addPullToRefreshWithActionHandler:block tintColor:[UIColor darkGrayColor] backgroundColor:[UIColor clearColor]];
}

- (void)addPullToRefreshWithActionHandler:(void (^)(void))block tintColor:(UIColor *)tintColor backgroundColor:(UIColor *)backgroundColor {
    self.pullToRefreshView = [[UIRefreshControl alloc] init];
    [self addSubview:self.pullToRefreshView];
    ((UIRefreshControl *)self.pullToRefreshView).tintColor = tintColor;
    ((UIRefreshControl *)self.pullToRefreshView).backgroundColor = backgroundColor;
    
    self.pullToRefreshBlock = block;
    [self.pullToRefreshView addTarget:self action:@selector(triggerPullToRefresh)
                     forControlEvents:UIControlEventValueChanged];
    
    
}

- (void)triggerPullToRefresh {
    self.pullToRefreshBlock();
}

- (void)beginRefreshing {
    [(UIRefreshControl *)self.pullToRefreshView beginRefreshing];

}

- (void)endRefreshing {
    [(UIRefreshControl *)self.pullToRefreshView endRefreshing];
}

- (BOOL)refreshing {
    return [(UIRefreshControl *)self.pullToRefreshView isRefreshing];

}

- (UIControl *)pullToRefreshView {
    return objc_getAssociatedObject(self, kPullToRefreshViewKey);
}

- (void)setPullToRefreshView:(UIControl *)pullToRefreshView {
    objc_setAssociatedObject(self, kPullToRefreshViewKey, pullToRefreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))pullToRefreshBlock {
    return objc_getAssociatedObject(self, kPullToRefreshBlockKey);
}

- (void)setPullToRefreshBlock:(void (^)(void))pullToRefreshBlock {
    objc_setAssociatedObject(self, kPullToRefreshBlockKey, pullToRefreshBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)placeHolderView {
    return objc_getAssociatedObject(self, kPlaceHolderViewKey);
}

- (void)setPlaceHolderView:(UIView *)placeHolderView {
    objc_setAssociatedObject(self, kPlaceHolderViewKey, placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addPlaceHolderView:(id)placeHolderView {
    if(!placeHolderView)
        return;
    
    self.placeHolderView = (UIView *)placeHolderView;
    self.placeHolderView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.placeHolderView.hidden = YES;
    [self addSubview:self.placeHolderView];
}

- (void)showPlaceHolder {
    if(!self.placeHolderView)
        return;
    
    [self bringSubviewToFront:self.placeHolderView];
    self.placeHolderView.hidden = NO;
}

- (void)hidePlaceHolder {
    if(!self.placeHolderView)
        return;
    
    self.placeHolderView.hidden = YES;
}

- (void)removePlaceHolderView {
    if(!self.placeHolderView)
        return;
    
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setContentInset:);
        SEL swizzledSelector = @selector(pulley_setContentInset:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)pulley_setContentInset:(UIEdgeInsets)contentInset {
    if (self.tracking) {
        CGFloat diff = contentInset.top - self.contentInset.top;
        CGPoint translation = [self.panGestureRecognizer translationInView:self];
        translation.y -= diff * 3.0 / 2.0;
        [self.panGestureRecognizer setTranslation:translation inView:self];
    }
    [self pulley_setContentInset:contentInset];
}


@end
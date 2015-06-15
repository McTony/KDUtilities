//
//  UIView+UIView_AnimateHiding.m
//  koudaixiang
//
//  Created by Liu Yachen on 11/15/11.
//  Copyright (c) 2011 Suixing Tech. All rights reserved.
//

#import "UIView+KDUtilities.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIView (KDUtilities)

- (UIView *)KD_addBlackOverlay {
    UIView *blackOverlay = [[UIView alloc] initWithFrame:self.bounds];
    blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    blackOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    blackOverlay.userInteractionEnabled = NO;

    [self insertSubview:blackOverlay atIndex:0];

    return blackOverlay;
}

- (UIView *)KD_addBorderOutsideWithWidth:(CGFloat)width
                                   color:(UIColor *)color
                            cornerRadius:(CGFloat)cornerRadius {
    UIView *view = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, -width, -width)];
    view.layer.borderWidth = width;
    view.layer.cornerRadius = cornerRadius;
    view.layer.borderColor = color.CGColor;
    view.userInteractionEnabled = NO;

    [self addSubview:view];
    
    return view;
}

static char __TapGestureRecognizerKey;
static char __TapActionKey;

- (void)KD_addTapAction:(void(^)(UIView *view))action {
    objc_setAssociatedObject(self,
                             &__TapActionKey,
                             action,
                             OBJC_ASSOCIATION_COPY);
    UITapGestureRecognizer *gr = objc_getAssociatedObject(self, &__TapGestureRecognizerKey);
    
    if (action) {
        self.userInteractionEnabled = YES;
        if (!gr) {
            gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(KD_tapped:)];
            [self addGestureRecognizer:gr];
            
            objc_setAssociatedObject(self,
                                     &__TapGestureRecognizerKey,
                                     gr,
                                     OBJC_ASSOCIATION_RETAIN);
        }
    } else {
        if (gr) {
            [self removeGestureRecognizer:gr];
            
            objc_setAssociatedObject(self,
                                     &__TapGestureRecognizerKey,
                                     nil,
                                     OBJC_ASSOCIATION_RETAIN);

        }
    }
}

- (void)KD_tapped:(UITapGestureRecognizer *)gr {
    void(^action)(UIView *view) = objc_getAssociatedObject(self, &__TapActionKey);
    action(self);
}

@end


@implementation UIView (AnimatedHiding)

- (void)KD_setHidden:(BOOL)hidden animationDuration:(NSTimeInterval)duration {
    if (self.hidden != hidden) {
        if (hidden) {
            __block UIView *selfInBlock = self;
            CGFloat originAlpha = self.alpha;
            [UIView animateWithDuration:duration 
                                  delay:0 
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{ 
                                 self.alpha = 0;
                             } 
                             completion:^(BOOL finished){
                                 selfInBlock.hidden = YES;
                                 selfInBlock.alpha = originAlpha;
                             }];
            
        } else {
            CGFloat originAlpha = self.alpha;
            self.hidden = NO;
            self.alpha = 0;
            [UIView animateWithDuration:duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{ 
                                 self.alpha = originAlpha;
                             } 
                             completion:NULL];
        }
    }
}

@end

@implementation UIView (FrameModifyHelper)

- (void)KD_setFrameOriginX:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}
- (void)KD_setFrameOriginY:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}
- (void)KD_setFrameSizeWidth:(CGFloat)value {
    CGRect frame = self.frame;
    frame.size.width = value;
    self.frame = frame;
}
- (void)KD_setFrameSizeHeight:(CGFloat)value {
    CGRect frame = self.frame;
    frame.size.height = value;
    self.frame = frame;
}

- (void)KD_setFrameOrigin:(CGPoint)value {
    CGRect frame = self.frame;
    frame.origin = value;
    self.frame = frame;
}
- (void)KD_setFrameSizeWidthBaseOnLeft:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.x -= value - frame.size.width;
    frame.size.width = value;
    self.frame = frame;
}

- (void)KD_setCenterAtSuperViewCenter {
    UIView *superview = self.superview;
    if (!superview) return;
    self.center = CGPointMake(superview.frame.size.width / 2.0f, superview.frame.size.height / 2.0f);
}

@end


const NSInteger FreezingImageViewTag = -100001;
static char HiddenStatusKey;

@implementation UIView (Freezing)

- (void)KD_freeze {
    if ([self KD_isFreezing])
        return;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSMutableArray *hiddenStatus = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for (int i = 0 ; i < self.subviews.count ; i++) {
        UIView *subview = (self.subviews)[i];
        [hiddenStatus addObject:@(subview.hidden)];
        subview.hidden = YES;
    }

    objc_setAssociatedObject(self,
                             &HiddenStatusKey,
                             hiddenStatus,
                             OBJC_ASSOCIATION_RETAIN);

    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    imageView.opaque = YES;
    imageView.tag = FreezingImageViewTag;
    [self addSubview:imageView];
}

- (void)KD_unfreeze {
    NSMutableArray *hiddenStatus = objc_getAssociatedObject(self, &HiddenStatusKey);
    if (hiddenStatus == nil) {
        return;
    }

    UIImageView *imageView = (UIImageView *)[self viewWithTag:FreezingImageViewTag];
    [imageView removeFromSuperview];

    for (int i = 0 ; i < self.subviews.count ; i++) {
        UIView *subview = (self.subviews)[i];
        subview.hidden = [hiddenStatus[i] boolValue];
    }

    objc_setAssociatedObject(self,
                             &HiddenStatusKey,
                             nil,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)KD_isFreezing {
    NSMutableArray *hiddenStatus = objc_getAssociatedObject(self, &HiddenStatusKey);
    return hiddenStatus != nil;
}

@end


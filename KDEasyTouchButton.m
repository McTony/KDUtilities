//
//  KDEasyTouchButton.m
//  koudaixiang
//
//  Created by Liu Yachen on 6/24/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDEasyTouchButton.h"

@implementation KDEasyTouchButton {
    BOOL _adjustAllRectWhenHighlighted;
    UIView *_darkView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        return YES;
    }else {
        return NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    BOOL same = highlighted == self.highlighted;
    [super setHighlighted:highlighted];

    if (same) return;

    if (_adjustAllRectWhenHighlighted) {
        if (highlighted) {
            _darkView.frame = self.bounds;
            [self sendSubviewToBack:_darkView];
            _darkView.alpha = 1;
        } else {
            if (_animatedDismissAllRectHighlighted) {
                [UIView animateWithDuration:0.6 animations:^{
                    _darkView.alpha = 0;
                }];
            } else {
                _darkView.alpha = 0;
            }
        }
    }
}

- (void)setAdjustAllRectWhenHighlighted:(BOOL)adjustAllRectWhenHighlighted {
    _adjustAllRectWhenHighlighted = adjustAllRectWhenHighlighted;
    self.adjustsImageWhenHighlighted = NO;

    if (adjustAllRectWhenHighlighted) {
        if (!_darkView) {
            _darkView = [[UIView alloc] initWithFrame:self.bounds];
            _darkView.backgroundColor = self.highlightMaskColor;
            _darkView.userInteractionEnabled = NO;
            _darkView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            _darkView.alpha = 0;
            [self addSubview:_darkView];
        }
    }
}

- (BOOL)adjustAllRectWhenHighlighted { return _adjustAllRectWhenHighlighted; }

- (UIColor *)highlightMaskColor {
    return _highlightMaskColor ?: [UIColor colorWithWhite:0 alpha:0.3];
}

- (void)setHighlightMaskColor:(UIColor *)highlightMaskColor {
    _highlightMaskColor = highlightMaskColor;
    _darkView.backgroundColor = highlightMaskColor;
}

@end

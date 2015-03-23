//
//  KDEasyTouchButton.h
//  koudaixiang
//
//  Created by Liu Yachen on 6/24/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDEasyTouchButton : UIButton {
    UIColor *_highlightMaskColor;
}

@property (nonatomic) BOOL adjustAllRectWhenHighlighted;
@property (nonatomic) BOOL animatedDismissAllRectHighlighted;

@property (nonatomic) UIColor *highlightMaskColor;

@end

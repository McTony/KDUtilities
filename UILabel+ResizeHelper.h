//
//  UILabel+ResizeHelper.h
//  Grouvent
//
//  Created by Blankwonder on 1/12/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ResizeHelper)

- (void)KD_resizeBaseOnLeft;
- (void)KD_resizeBaseOnRight;

- (void)KD_resizeBaseOnTopWithMaxHeight:(CGFloat)height;
- (void)KD_resizeBaseOnBottomWithMaxHeight:(CGFloat)height;

@end


@interface NSString (ResizeHelper)

- (CGSize)KD_sizeWithAttributeFont:(UIFont *)font;

@end
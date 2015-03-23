//
//  UILabel+ResizeHelper.m
//  Grouvent
//
//  Created by Blankwonder on 1/12/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "UILabel+ResizeHelper.h"
#import "UIView+KDUtilities.h"
#import "KDUtilities.h"

@implementation UILabel (ResizeHelper)

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)KD_resizeBaseOnLeft {
    CGSize size = [self.text KD_sizeWithAttributeFont:self.font];
    [self KD_setFrameSizeWidth:ceilf(size.width)];
}

- (void)KD_resizeBaseOnRight {

    CGSize size = [self.text KD_sizeWithAttributeFont:self.font];
    CGRect frame = self.frame;
    CGFloat delta = frame.size.width - size.width;
    frame.size.width = size.width;
    frame.origin.x += delta;
    self.frame = frame;
}
- (void)KD_resizeBaseOnTopWithMaxHeight:(CGFloat)height {
    CGSize size;
#ifdef __IPHONE_7_0
    if (KDUtilIsOSMajorVersionHigherOrEqual(7)) {
        size = [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, height)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: self.font}
                                       context:NULL].size;
    } else {
        size = [self.text sizeWithFont:self.font
                     constrainedToSize:CGSizeMake(self.bounds.size.width, height)
                         lineBreakMode:self.lineBreakMode];
    }
#else
    size = [self.text sizeWithFont:self.font
                 constrainedToSize:CGSizeMake(self.bounds.size.width, height)
                     lineBreakMode:self.lineBreakMode];
#endif
    [self KD_setFrameSizeHeight:ceilf(size.height)];
}

- (void)KD_resizeBaseOnBottomWithMaxHeight:(CGFloat)height {
    CGSize size;
#ifdef __IPHONE_7_0
    if (KDUtilIsOSMajorVersionHigherOrEqual(7)) {
        size = [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, height)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: self.font}
                                       context:NULL].size;
    } else {
        size = [self.text sizeWithFont:self.font
                     constrainedToSize:CGSizeMake(self.bounds.size.width, height)
                         lineBreakMode:self.lineBreakMode];
    }
#else
    size = [self.text sizeWithFont:self.font
                 constrainedToSize:CGSizeMake(self.bounds.size.width, height)
                     lineBreakMode:self.lineBreakMode];
#endif
    CGRect frame = self.frame;
    frame.origin.y += frame.size.height - size.height;
    frame.size.height = ceilf(size.height);
    self.frame = frame;
}

@end


@implementation NSString (BBSize)

- (CGSize)KD_sizeWithAttributeFont:(UIFont *)font {
#ifdef __IPHONE_7_0
    if (KDUtilIsOSMajorVersionHigherOrEqual(7)) {
        return [self sizeWithAttributes:@{NSFontAttributeName: font}];
    } else {
        return [self sizeWithFont:font];
    }
#else
    return [self sizeWithFont:font];
#endif
}

@end


#pragma GCC diagnostic warning "-Wdeprecated-declarations"

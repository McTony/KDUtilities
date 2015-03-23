//
//  KDColorHelper.m
//  BuddyBook
//
//  Created by Blankwonder on 10/17/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "KDColorHelper.h"

@implementation UIColor (ColorCode)

- (NSUInteger)KD_colorCode
{
    CGFloat red, green, blue, alpha;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha])
    {
        NSUInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSUInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSUInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        NSUInteger alphaInt = (NSUInteger)(alpha * 255 + 0.5);

        return (alphaInt << 24) | (redInt << 16) | (greenInt << 8) | blueInt;
    }

    return 0;
}

+ (UIColor *)KD_colorWithCode:(NSUInteger)hex
{
    int a = (hex >> 24) & 0xFF;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:a / 255.0f];
}


@end

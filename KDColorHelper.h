//
//  KDColorHelper.h
//  BuddyBook
//
//  Created by Blankwonder on 10/17/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorCode)

- (NSUInteger)KD_colorCode;
+ (UIColor *)KD_colorWithCode:(NSUInteger)hex;

@end
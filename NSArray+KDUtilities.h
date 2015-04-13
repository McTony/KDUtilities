//
//  NSArray+KDUtilities.h
//  zhonghaijinchao
//
//  Created by Blankwonder on 4/10/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (KDUtilities)

- (NSArray *)KD_arrayUsingMapEnumerateBlock:(id (^)(id obj, NSUInteger idx))block;

@end

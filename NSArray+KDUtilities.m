//
//  NSArray+KDUtilities.m
//  zhonghaijinchao
//
//  Created by Blankwonder on 4/10/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import "NSArray+KDUtilities.h"

@implementation NSArray (KDUtilities)

- (NSArray *)KD_arrayUsingMapEnumerateBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSObject *newObj = block(obj, idx);
        if (newObj) {
            [newArray addObject:newObj];
        }
    }];
    
    return [newArray copy];
}

@end

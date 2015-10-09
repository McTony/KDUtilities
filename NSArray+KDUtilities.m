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

- (id)KD_randomObject{
    return self.count == 0 ? nil : self[arc4random_uniform((unsigned int)self.count)];
}

- (NSArray *)KD_shuffledArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    return [array copy];
}

@end

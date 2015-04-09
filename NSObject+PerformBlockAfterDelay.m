//
//  NSObject+PerformBlockAfterDelay.m
//  BuddyBook
//
//  Created by Blankwonder on 8/29/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "NSObject+PerformBlockAfterDelay.h"

@implementation NSObject (PerformBlockAfterDelay)

- (void)KD_performBlock:(void (^)(void))block
             afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(KD_fireBlock:)
               withObject:[block copy]
               afterDelay:delay];
}

- (void)KD_fireBlock:(void (^)(void))block {
    block();
}

@end

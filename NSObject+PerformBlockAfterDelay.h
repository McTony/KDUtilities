//
//  NSObject+PerformBlockAfterDelay.h
//  BuddyBook
//
//  Created by Blankwonder on 8/29/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlockAfterDelay)

- (void)KD_performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay;

@end

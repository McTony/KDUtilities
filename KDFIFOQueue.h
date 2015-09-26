//
//  KDFIFOQueue.h
//  Surge-iOS
//
//  Created by Blankwonder on 9/20/15.
//  Copyright © 2015 Yach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDFIFOQueue : NSObject

- (id)dequeue;
- (void)enqueue:(id)anObject;

- (NSArray *)allObjects;
- (NSUInteger)count;

@property NSInteger maxQueueSize; // First object will dequeue automatically if overflow

@end

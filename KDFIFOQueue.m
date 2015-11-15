//
//  KDFIFOQueue.m
//  Surge-iOS
//
//  Created by Blankwonder on 9/20/15.
//  Copyright © 2015 Yach. All rights reserved.
//

#import "KDFIFOQueue.h"

@interface KDFIFOQueueNode : NSObject

@property KDFIFOQueueNode *nextNode;
@property id payload;

@end

@implementation KDFIFOQueue {
    KDFIFOQueueNode *_firstNode, *_lastNode;
    int _count;
}

- (id)dequeue{
    @autoreleasepool {
        if (_firstNode == nil) return nil;
        
        KDFIFOQueueNode *node = _firstNode;
        _firstNode = node.nextNode;
        
        node.nextNode = nil;
        
        if (_firstNode == nil) {
            _lastNode = nil;
        }
        
        _count--;
        
        return node.payload;
    }
}

- (id)peek {
    return _firstNode.payload;
}

- (void)enqueue:(id)anObject {
    @autoreleasepool {
        KDFIFOQueueNode *newNode = [[KDFIFOQueueNode alloc] init];
        newNode.payload = anObject;
        
        if (_firstNode == nil) {
            _firstNode = newNode;
            _lastNode = newNode;
            
            _count = 1;
        } else {
            _lastNode.nextNode = newNode;
            _lastNode = newNode;
            
            _count++;
            
            if (self.maxQueueSize > 0) {
                while (_count > self.maxQueueSize) {
                    [self dequeue];
                }
            }
        }
    }
}

- (NSArray *)allObjects {
    NSMutableArray *array = [NSMutableArray array];
    
    KDFIFOQueueNode *lastNode = _firstNode;
    
    while (lastNode) {
        [array addObject:lastNode.payload];
        lastNode = lastNode.nextNode;
    }
    
    return [array copy];
}

- (NSUInteger)count {
    return _count;
}

@end

@implementation KDFIFOQueueNode

@end
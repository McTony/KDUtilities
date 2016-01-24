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
    NSLock *_lock;
    int _count;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (id)dequeue{
    return [self dequeueWithLock:YES];
}

- (id)dequeueWithLock:(BOOL)needLock {
    if (needLock) {
        [_lock lock];
    }
    
    if (_firstNode == nil) {
        if (needLock) {
            [_lock unlock];
        }
        return nil;
    }
    
    KDFIFOQueueNode *node = _firstNode;
    _firstNode = node.nextNode;
    
    node.nextNode = nil;
    
    if (_firstNode == nil) {
        _lastNode = nil;
    }
    
    _count--;
    if (needLock) {
        [_lock unlock];
    }
    return node.payload;
}

- (id)peek {
    [_lock lock];
    id result = _firstNode.payload;
    [_lock unlock];
    return result;
}

- (void)enqueue:(id)anObject {
    [_lock lock];

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
                [self dequeueWithLock:NO];
            }
        }
    }
    [_lock unlock];
}

- (NSArray *)allObjects {
    [_lock lock];

    NSMutableArray *array = [NSMutableArray array];
    
    KDFIFOQueueNode *lastNode = _firstNode;
    
    while (lastNode) {
        [array addObject:lastNode.payload];
        lastNode = lastNode.nextNode;
    }
    [_lock unlock];

    return [array copy];
}

- (NSUInteger)count {
    [_lock lock];
    NSUInteger result = _count;
    [_lock unlock];
    return result;
}

@end

@implementation KDFIFOQueueNode

@end
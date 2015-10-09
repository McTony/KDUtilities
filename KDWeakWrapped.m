//
//  KDWeakWrapped.m
//  Surge-iOS
//
//  Created by Blankwonder on 9/27/15.
//  Copyright © 2015 Yach. All rights reserved.
//

#import "KDWeakWrapped.h"

@implementation KDWeakWrapped

- (instancetype)initWithObject:(id)obj {
    self = [self init];
    if (self) {
        _obj = obj;
    }
    return self;
}

- (id)object {
    return _obj;
}

@end

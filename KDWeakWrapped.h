//
//  KDWeakWrapped.h
//  Surge-iOS
//
//  Created by Blankwonder on 9/27/15.
//  Copyright © 2015 Yach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDWeakWrapped : NSObject {
    __weak id _obj;
}

- (instancetype)initWithObject:(id)obj;

- (id)object;

@end

//
//  KDCUtil.h
//  koudaixiang
//
//  Created by Liu Yachen on 2/13/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KDAssertRequireMainThread() NSAssert([NSThread isMainThread], @"This method can only be invoked on main thread!");

#define KDUtilRemoveNotificationCenterObserverDealloc - (void)dealloc{ [[NSNotificationCenter defaultCenter] removeObserver:self]; }

NS_INLINE BOOL KDUtilIsObjectNull(id object) {
    return object == nil || object == [NSNull null];
}

NS_INLINE BOOL KDUtilIsStringValid(NSString *str) {
    return str != nil && (id)str != [NSNull null] && ![str isEqualToString:@""];
}

extern BOOL KDUtilIsOSVersionHigherOrEqual(NSString* version);
extern BOOL KDUtilIsOSMajorVersionHigherOrEqual(int version);

NS_INLINE BOOL KDUtilIs4InchScreen() {
    return [UIScreen mainScreen].bounds.size.height == 568.0;
}

extern UIView *KDUtilFindViewInSuperViews(UIView *view, Class viewClass);

extern NSNumber *KDUtilIntegerValueNumberGuard(id obj);
extern NSString *KDUtilStringGuard(id obj);
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

#define KDUtilDefineWeakSelfRef __weak id weakSelf = self;

NS_INLINE BOOL KDUtilIsObjectNull(id object) {
    return object == nil || object == [NSNull null];
}

NS_INLINE BOOL KDUtilIsStringValid(NSString *str) {
    return str != nil && (id)str != [NSNull null] && ![str isEqualToString:@""];
}

extern BOOL KDUtilIsOSVersionHigherOrEqual(NSString* version);
extern BOOL KDUtilIsOSMajorVersionHigherOrEqual(int version);

NS_INLINE CGFloat KDUtilScreenWidth() {
    return [UIScreen mainScreen].bounds.size.width;
}

extern UIView *KDUtilFindViewInSuperViews(UIView *view, Class viewClass);

extern NSNumber *KDUtilIntegerValueNumberGuard(id obj);
extern NSString *KDUtilStringGuard(id obj);

extern BOOL KDUtilIsDeviceJailbroken();
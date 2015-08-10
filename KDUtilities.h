//
//  KDCUtil.h
//  koudaixiang
//
//  Created by Liu Yachen on 2/13/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KDAssertRequireMainThread() KDAssert([NSThread isMainThread], @"This method can only be invoked on main thread!");
#define KDAssertRequirePad() KDAssert(KDUtilIsDevicePad(), @"This method can only be invoked on iPad!");
#define KDAssertRequireNotPad() KDAssert(!KDUtilIsDevicePad(), @"This method can not be invoked on iPad!");

#define KDUtilRemoveNotificationCenterObserverDealloc - (void)dealloc{ [[NSNotificationCenter defaultCenter] removeObserver:self]; }

#define KDUtilDefineWeakSelfRef __weak __typeof(self) weakSelf = self;

#define KDUtilThrowNoImplementationException @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"This method has not been implemented: %@", NSStringFromSelector(_cmd)] userInfo:nil];


NS_INLINE BOOL KDUtilIsObjectNull(id object) {
    return object == nil || object == [NSNull null];
}

NS_INLINE BOOL KDUtilIsStringValid(NSString *str) {
    return str != nil && (id)str != [NSNull null] && ![str isEqualToString:@""];
}

NS_INLINE NSString *KDUtilStringWithInvalidPlaceholder(NSString *str, NSString *placeholder) {
    return KDUtilIsStringValid(str) ? str : placeholder;
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

NS_INLINE BOOL KDUtilIsDevicePad() {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

extern void KDAssert(BOOL eval, NSString *format, ...);
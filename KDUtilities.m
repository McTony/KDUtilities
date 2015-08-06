//
//  KDCUtil.c
//  koudaixiang
//
//  Created by Liu Yachen on 2/13/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDUtilities.h"
#import "KDAlertView.h"
#import <UIKit/UIKit.h>

NSComparisonResult _compareVersions(NSString* leftVersion, NSString* rightVersion)
{
    int i;
    
    // Break version into fields (separated by '.')
    NSMutableArray *leftFields = [[NSMutableArray alloc] initWithArray:[leftVersion componentsSeparatedByString:@"."]];
    NSMutableArray *rightFields = [[NSMutableArray alloc] initWithArray:[rightVersion componentsSeparatedByString:@"."]];
    
    // Implict ".0" in case version doesn't have the same number of '.'
    if ([leftFields count] < [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [leftFields addObject:@"0"];
        }
    } else if ([leftFields count] > [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [rightFields addObject:@"0"];
        }
    }
    
    // Do a numeric comparison on each field
    for(i = 0; i < [leftFields count]; i++) {
        NSComparisonResult result = [leftFields[i] compare:rightFields[i] options:NSNumericSearch];
        if (result != NSOrderedSame) {
            return result;
        }
    }
    
    return NSOrderedSame;
}

BOOL KDUtilIsOSVersionHigherOrEqual(NSString* version) {
    return (_compareVersions([[UIDevice currentDevice] systemVersion], version) != NSOrderedAscending);
}

extern BOOL KDUtilIsOSMajorVersionHigherOrEqual(int version) {
    static int OSMajorVersion;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        OSMajorVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    });

    return OSMajorVersion >= version;
}

extern UIView *KDUtilFindViewInSuperViews(UIView *view, Class viewClass) {
    while (view != nil) {
        view = view.superview;
        if ([view isKindOfClass:viewClass]) return view;
    }
    return nil;
}

extern NSNumber *KDUtilIntegerValueNumberGuard(id obj) {
    if (!obj) return nil;
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return @([(NSString *)obj integerValue]);
    }
    return nil;
}

extern NSString *KDUtilStringGuard(id obj) {
    if (!obj) return nil;
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj stringValue];
    }
    return nil;
}


extern BOOL KDUtilIsDeviceJailbroken() {
#if !(TARGET_IPHONE_SIMULATOR)
    
    static dispatch_once_t pred;
    static BOOL jailbroken = NO;
    
    dispatch_once(&pred, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"])  {
            jailbroken = YES;
            return;
        }
        
        FILE *f = NULL ;
        if ((f = fopen("/bin/bash", "r")) ||
            (f = fopen("/Applications/Cydia.app", "r")) ||
            (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
            (f = fopen("/usr/sbin/sshd", "r")) ||
            (f = fopen("/etc/apt", "r")))  {
            jailbroken = YES;
        }
        if (f) fclose(f);
    });
    
    return jailbroken;
#endif
    
    return NO;
}

extern void KDAssert(BOOL eval, NSString *format, ...) {
    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    if (!eval) {
        [[[KDAlertView alloc] initWithTitle:@"Fatal Error" message:message cancelButtonTitle:@"OK" cancelAction:nil] show];
#if DEBUG
        [NSException raise:NSInternalInconsistencyException format:format arguments:ap];
#endif
    }
    va_end(ap);
}

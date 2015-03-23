//
//  BBAppDelegate+UserDefault.m
//  BuddyBook
//
//  Created by Blankwonder on 8/18/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "KDUserDefault.h"

@implementation KDUserDefault

+ (instancetype)sharedDefault;
{
    static dispatch_once_t pred;
    __strong static KDUserDefault *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[KDUserDefault alloc] init];
    });

    return sharedInstance;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSString *sel = NSStringFromSelector(selector);
    if ([sel hasPrefix:@"set"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *key = NSStringFromSelector([invocation selector]);
    if ([key hasPrefix:@"set"]) {
        key = [key substringWithRange:NSMakeRange(3, [key length]-4)];
        NSString *kvoKey = [key stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                        withString:[[key substringToIndex:1] lowercaseString]];

        __unsafe_unretained id value = nil;
        [invocation getArgument:&value atIndex:2];

        [self willChangeValueForKey:kvoKey];
        if (value) {
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [self didChangeValueForKey:kvoKey];
    } else {
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                           withString:[[key substringToIndex:1] uppercaseString]];

        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        [invocation setReturnValue:&obj];
        [invocation retainArguments];
    }
}

@end

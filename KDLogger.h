//
//  KDLogger.h
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KDLog(...) _KDLog(__VA_ARGS__)
#define KDClassLog(...) _KDLog(NSStringFromClass([self class]), __VA_ARGS__)

typedef void(^KDLoggerCustomActionBlock)(NSString *message);

extern void _KDLog(NSString *module, NSString *format, ...);

extern void KDLoggerSetEnabled(BOOL enabled);

extern void KDLoggerSetLogCustomActionBlock(KDLoggerCustomActionBlock block);

extern void KDLoggerSetLogFilePath(NSString *path);
NSString *KDLoggerGetLogFilePath();

extern void KDLoggerInstallUncaughtExceptionHandler();

extern void KDLoggerPrintCallStack();

#if TARGET_OS_IOS
extern void KDLoggerPrintEnviroment();
#endif
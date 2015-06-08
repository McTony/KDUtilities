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

typedef void(^KDDebuggerCustomActionBlock)(NSString *message);

void _KDLog(NSString *module, NSString *format, ...);

void KDDebuggerSetLogCustomActionBlock(KDDebuggerCustomActionBlock block);

void KDDebuggerSetLogFilePath(NSString *path);
NSString *KDDebuggerGetLogFilePath(void);

void KDDebuggerInstallUncaughtExceptionHandler(void);

void KDDebuggerPrintCallStack(void);
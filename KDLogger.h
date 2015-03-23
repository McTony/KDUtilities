//
//  KDLogger.h
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define KDLog(...) _KDLog(__VA_ARGS__) 
#   define KDClassLog(...) _KDLog(NSStringFromClass([self class]), __VA_ARGS__)
#else
#   define KDLog(...) do{}while(0)
#   define KDClassLog(...) do{}while(0)
#endif

typedef void(^KDDebuggerCustomActionBlock)(NSString *message);

void _KDLog(NSString *module, NSString *format, ...);

void KDDebuggerSetLogCustomActionBlock(KDDebuggerCustomActionBlock block);

void KDDebuggerSetLogDirectory(NSString *path);
void KDDebuggerInstallUncaughtExceptionHandler(void);

void KDDebuggerPrintCallStack(void);
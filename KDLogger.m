//
//  KDDebugger.c
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDLogger.h"
#include <execinfo.h>

static NSFileHandle *__logFileHandle;
static NSString *__logFilePath;

static NSUncaughtExceptionHandler *__previousExceptionHandler;
static KDDebuggerCustomActionBlock __customActionBlock;

void KDDebuggerSetLogFilePath(NSString *path) {
    if (__logFileHandle) {
        [__logFileHandle closeFile];
        __logFileHandle = nil;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    
    __logFilePath = [path copy];
    __logFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [__logFileHandle seekToEndOfFile];
}

void _KDLog(NSString *module, NSString *format, ...) {
    static dispatch_once_t pred;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&pred, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HHmmss"];
    });

    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    NSString *log;
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    if ([NSThread isMainThread]) {
        log = [[NSString alloc] initWithFormat:@"%@  [%@] %@\n", dateStr, module, message];
    } else {
        log = [[NSString alloc] initWithFormat:@"%@ *[%@] %@\n", dateStr, module, message];
    }

    fputs(log.UTF8String, stderr);
    
    if (__logFileHandle) {
        NSData *logFileData = [log dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async( dispatch_get_main_queue(),^{
            [__logFileHandle writeData:logFileData];
            [__logFileHandle synchronizeFile];
        });
    }

    if (__customActionBlock) {
        __customActionBlock(log);
    }
}

void KDHandleException(NSException* exception) {
    KDLog(@"KDLogger", @"Uncaught Exception, description:%@, call stack:%@",
           exception.description,
           [exception callStackSymbols]);
    if (__previousExceptionHandler) {
        __previousExceptionHandler(exception);
    }
}

void KDDebuggerInstallUncaughtExceptionHandler(void) {
    __previousExceptionHandler = NSGetUncaughtExceptionHandler();
	NSSetUncaughtExceptionHandler(&KDHandleException);
}

void KDDebuggerPrintCallStack(void)
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int  i = 0; i < frames; i++)
    {
	 	[backtrace addObject:@(strs[i])];
    }
    free(strs);
    
    KDLog(@"KDLogger", @"Call stack:%@", backtrace);
}

void KDDebuggerSetLogCustomActionBlock(KDDebuggerCustomActionBlock block) {
    __customActionBlock = [block copy];
}

NSString *KDDebuggerGetLogFilePath(void) {
    return __logFilePath;
}

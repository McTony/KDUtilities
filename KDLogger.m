//
//  KDDebugger.c
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDLogger.h"
#include <execinfo.h>

static NSString *_LogFileDirectory;
static NSFileHandle *_LogFileHandle;

static NSUncaughtExceptionHandler *_PreviousExceptionHandler;
static KDDebuggerCustomActionBlock _CustomActionBlock;

void KDDebuggerSetLogDirectory(NSString *path) {
    if (![_LogFileDirectory isEqual:path]) {
        _LogFileDirectory = [path copy];

        if (_LogFileHandle) {
            [_LogFileHandle closeFile];
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        NSString *path = [_LogFileDirectory stringByAppendingPathComponent:[dateStr stringByAppendingPathExtension:@"log"]];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        _LogFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        [_LogFileHandle seekToEndOfFile];
    }
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
    
    if (_LogFileHandle) {
        NSData *logFileData = [log dataUsingEncoding:NSUTF8StringEncoding];
        @synchronized(_LogFileHandle) {
            [_LogFileHandle writeData:logFileData];
            [_LogFileHandle synchronizeFile];
        }
    }

    if (_CustomActionBlock) {
        _CustomActionBlock(log);
    }
}

void KDHandleException(NSException* exception)
{
    KDLog(@"KDLogger", @"Uncaught Exception, description:%@, call stack:%@",
           exception.description,
           [exception callStackSymbols]);
    if (_PreviousExceptionHandler) {
        _PreviousExceptionHandler(exception);
    }
}

void KDDebuggerInstallUncaughtExceptionHandler(void)
{
    _PreviousExceptionHandler = NSGetUncaughtExceptionHandler();
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
    _CustomActionBlock = [block copy];
}
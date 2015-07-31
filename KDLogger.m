//
//  KDLogger.c
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDLogger.h"
#include <execinfo.h>
#import <sys/utsname.h>
#import <asl.h>

static NSFileHandle *__logFileHandle;
static NSString *__logFilePath;

static NSUncaughtExceptionHandler *__previousExceptionHandler;
static KDLoggerCustomActionBlock __customActionBlock;

static BOOL __loggerEnabled = YES;
void KDLoggerSetEnabled(BOOL enabled) {
    __loggerEnabled = enabled;
}


void KDLoggerSetLogFilePath(NSString *path) {
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
    if (!__loggerEnabled) return;
    
    static dispatch_once_t pred;
    static NSDateFormatter *dateFormatter;
    static aslclient aslclient;

    dispatch_once(&pred, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HHmmss"];
        
        aslclient = asl_open(NULL, "com.apple.console", 0);
    });

    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    NSString *line = [[NSString alloc] initWithFormat:[NSThread isMainThread] ? @"%@  [%@] %@\n" : @"%@ *[%@] %@\n",
                      [dateFormatter stringFromDate:[NSDate date]],
                      module,
                      message];
    
    fputs(line.UTF8String, stderr);
    {
        uid_t const readUID = geteuid();
        char readUIDString[16];
        snprintf(readUIDString, sizeof(readUIDString), "%d", readUID);
        
        aslmsg m = asl_new(ASL_TYPE_MSG);
        if (m != NULL) {
            if (asl_set(m, ASL_KEY_LEVEL, "5") == 0 &&
                asl_set(m, ASL_KEY_MSG, line.UTF8String) == 0 &&
                asl_set(m, ASL_KEY_READ_UID, readUIDString) == 0) {
                asl_send(aslclient, m);
            }
            asl_free(m);
        }
    }
    
    if (__logFileHandle) {
        NSData *lineData = [line dataUsingEncoding:NSUTF8StringEncoding];
        void (^action)() = ^{
            [__logFileHandle writeData:lineData];
            [__logFileHandle synchronizeFile];
        };
        
        if ([NSThread isMainThread]) {
            action();
        } else {
            dispatch_sync( dispatch_get_main_queue(), action);
        }
    }

    if (__customActionBlock) {
        __customActionBlock(line);
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

void KDLoggerInstallUncaughtExceptionHandler(void) {
    __previousExceptionHandler = NSGetUncaughtExceptionHandler();
	NSSetUncaughtExceptionHandler(&KDHandleException);
}

void KDLoggerPrintCallStack(void) {
    void *callstack[128];
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

void KDLoggerSetLogCustomActionBlock(KDLoggerCustomActionBlock block) {
    __customActionBlock = [block copy];
}

void KDLoggerPrintEnviroment() {
    UIDevice *currentDevice = [UIDevice currentDevice];
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    KDLog(@"KDLogger", @"Enviroment: %@, %@, %@(%@), Jailbroken: %@", @(systemInfo.machine), [currentDevice systemVersion], infoDictionary[@"CFBundleShortVersionString"], infoDictionary[@"CFBundleVersion"], KDUtilIsDeviceJailbroken() ? @"YES": @"NO");
}

NSString *KDLoggerGetLogFilePath(void) {
    return __logFilePath;
}

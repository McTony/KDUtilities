//
//  KDLogger.c
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDLogger.h"
#import <execinfo.h>
#import <sys/utsname.h>
#import <asl.h>
#import "KDUtilities.h"
#import <sys/event.h>

static NSFileHandle *__logFileHandle;
static NSString *__logFilePath;

static NSUncaughtExceptionHandler *__previousExceptionHandler;
static KDLoggerCustomActionBlock __customActionBlock;

static dispatch_queue_t __dispatchQueue;

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
    dispatch_once(&pred, ^{
        __dispatchQueue = dispatch_queue_create("KDLogger", NULL);
    });
    
    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    NSString *symbol = [NSThread isMainThread] ? @"*": @" ";
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    dispatch_sync(__dispatchQueue, ^{
        @autoreleasepool {
            NSString *line = [[NSString alloc] initWithFormat:@"%02d%02d%02d %@[%@] %@\n",
                              (int)nowComponents.hour, (int)nowComponents.minute, (int)nowComponents.second,
                              symbol,
                              module,
                              message];
            
#if DEBUG
            fputs(line.UTF8String, stderr);
            static dispatch_once_t pred;
            static aslclient aslclient;
            
            dispatch_once(&pred, ^{
                aslclient = asl_open(NULL, "com.apple.console", 0);
            });
            
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
#endif
            
            if (__logFileHandle) {
                NSData *lineData = [line dataUsingEncoding:NSUTF8StringEncoding];
                
                [__logFileHandle writeData:lineData];
                [__logFileHandle synchronizeFile];
            }
            
            if (__customActionBlock) {
                __customActionBlock(line);
            }
        }
    });

}

void KDLoggerExceptionHandler(NSException* exception) {
    KDLog(@"KDLogger", @"Uncaught Exception, description:%@, call stack:%@",
           exception.description,
           [exception callStackSymbols]);
    if (__previousExceptionHandler) {
        __previousExceptionHandler(exception);
    }
}

void KDLoggerInstallUncaughtExceptionHandler(void) {
    __previousExceptionHandler = NSGetUncaughtExceptionHandler();
	NSSetUncaughtExceptionHandler(&KDLoggerExceptionHandler);
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

NSString *KDLoggerGetLogFilePath(void) {
    return __logFilePath;
}

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>

void KDLoggerPrintEnviroment() {
    UIDevice *currentDevice = [UIDevice currentDevice];
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    KDLog(@"KDLogger", @"Enviroment: %@, %@, %@(%@)", @(systemInfo.machine), [currentDevice systemVersion], infoDictionary[@"CFBundleShortVersionString"], infoDictionary[@"CFBundleVersion"]);
}

#endif


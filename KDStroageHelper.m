//
//  KDStroageHelper.m
//  Beacon Calendar
//
//  Created by Blankwonder on 8/4/14.
//
//

#import "KDStroageHelper.h"
#import "KDLogger.h"


@implementation KDStroageHelper

+ (void)load {
    KDClassLog(@"Bundle path: %@", [[NSBundle mainBundle] bundlePath]);
}

+ (NSString *)libraryDirectoryPath {
    static dispatch_once_t pred;
    __strong static id libraryPath = nil;
    
    dispatch_once(&pred, ^{
        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        libraryPath = libraryPaths.firstObject;
    });
    return libraryPath;
}

+ (NSString *)cacheDirectoryPath {
    static dispatch_once_t pred;
    __strong static id cachePath = nil;
    
    dispatch_once(&pred, ^{
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachePath = cachePaths.firstObject;
    });
    return cachePath;
}

+ (NSString *)temporaryDirectoryPath {
    return NSTemporaryDirectory();
}

@end

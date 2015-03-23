//
//  KDStroageHelper.m
//  Beacon Calendar
//
//  Created by Blankwonder on 8/4/14.
//
//

#import "KDStroageHelper.h"
#import "KDLogger.h"

static NSString *cachePath;
static NSString *libraryPath;

@implementation KDStroageHelper

+ (void)initialize {
    KDClassLog(@"Bundle path: %@", [[NSBundle mainBundle] bundlePath]);

    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cachePath = cachePaths[0];
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    libraryPath = libraryPaths[0];
}

+ (NSString *)libraryPath {
    return libraryPath;
}

+ (NSString *)cachePath {
    return cachePath;
}

@end

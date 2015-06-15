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

+ (NSString *)libraryDataStorageDirectoryPath {
    return [[self libraryDirectoryPath] stringByAppendingPathComponent:@"KDStroageHelper"];
}

+ (void)writeDataToLibrary:(NSData *)data identifier:(NSString *)identifier {
    NSString *dir = [self libraryDataStorageDirectoryPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            KDClassLog(@"Error occurred when create directory: %@", error);
            return;
        }
    }
    [data writeToFile:[dir stringByAppendingPathComponent:identifier] atomically:YES];
    
    KDClassLog(@"Write data object: %@, bytes: %lu", identifier, data.length);
}

+ (NSData *)dataFromLibraryWithIdentifier:(NSString *)identifier {
    return [NSData dataWithContentsOfFile:[[self libraryDataStorageDirectoryPath] stringByAppendingPathComponent:identifier]];
}

@end

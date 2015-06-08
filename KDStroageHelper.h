//
//  KDStroageHelper.h
//  Beacon Calendar
//
//  Created by Blankwonder on 8/4/14.
//
//

#import <Foundation/Foundation.h>

@interface KDStroageHelper : NSObject

+ (NSString *)libraryDirectoryPath;
+ (NSString *)cacheDirectoryPath;
+ (NSString *)temporaryDirectoryPath;

@end

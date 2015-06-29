//
//  NSData+KDUtilities.m
//  Kata
//
//  Created by Blankwonder on 6/27/15.
//  Copyright © 2015 Daxiang. All rights reserved.
//

#import "NSData+KDUtilities.h"

@implementation NSData (KDUtilities)

- (NSString *)stringWithUTF8Encoding {
    return [self stringWithEncoding:NSUTF8StringEncoding];
}
- (NSString *)stringWithEncoding:(NSStringEncoding)encoding {
    return [[NSString alloc] initWithData:self encoding:encoding];
}

@end

//
//  NSData+JSONHelper.m
//  Golf
//
//  Created by Blankwonder on 6/3/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "KDJSONHelper.h"
#import <objc/runtime.h>
#import "KDLogger.h"

static char NSDataAssociatedJSONObject;

@implementation NSData (KDJSONHelper)
- (id)KD_JSONObject {
    NSDictionary *result  = objc_getAssociatedObject(self, &NSDataAssociatedJSONObject);
    if (result) {
        return result;
    }

    NSError *error;
    result = [NSJSONSerialization JSONObjectWithData:self options:0 error:&error];
    if (error) {
        KDLog(@"JSONHelper", @"Error occered when JSON deserializate NSData to object: %@", error);
        return nil;
    }

    objc_setAssociatedObject(self,
                             &NSDataAssociatedJSONObject,
                             result,
                             OBJC_ASSOCIATION_RETAIN);

    return result;
}
@end

static NSData *JSONDataFromObject(id object) {
    NSError *error;
    NSData *result = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        KDLog(@"JSONHelper", @"Error occered when JSON deserializate NSData to object: %@", error);
        return nil;
    }

    objc_setAssociatedObject(result,
                             &NSDataAssociatedJSONObject,
                             object,
                             OBJC_ASSOCIATION_RETAIN);

    return result;
}

static NSString *JSONStringFromObject(id object) {
    NSData *data = JSONDataFromObject(object);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@implementation NSDictionary (KDJSONHelper)

- (NSData *)KD_JSONData {
    return JSONDataFromObject(self);
}

- (NSString *)KD_JSONString {
    return JSONStringFromObject(self);
}

@end

@implementation NSArray (KDJSONHelper)

- (NSData *)KD_JSONData {
    return JSONDataFromObject(self);
}

- (NSString *)KD_JSONString {
    return JSONStringFromObject(self);
}

@end
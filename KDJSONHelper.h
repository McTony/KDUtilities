//
//  NSData+JSONHelper.h
//  Golf
//
//  Created by Blankwonder on 6/3/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (KDJSONHelper)
- (id)KD_JSONObject;
@end

@interface NSDictionary (KDJSONHelper)
- (NSData *)KD_JSONData;
- (NSString *)KD_JSONString;
@end

@interface NSArray (KDJSONHelper)
- (NSData *)KD_JSONData;
- (NSString *)KD_JSONString;
@end
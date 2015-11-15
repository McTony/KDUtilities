//
//  NSURL+KDUtilites.m
//  Surge-iOS
//
//  Created by Blankwonder on 11/14/15.
//  Copyright © 2015 Yach. All rights reserved.
//

#import "NSURL+KDUtilites.h"

@implementation NSURL (KDUtilites)

- (NSDictionary *)queryDictionary {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [[self.query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *comps = [obj componentsSeparatedByString:@"="];
        if (comps.count == 2) {
            query[comps[0]] = comps[1];
        }
    }];

    return [query copy];
}

@end

//
//  Keychain.h
//  Netpas
//
//  Created by Blankwonder on 3/26/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject

+ (BOOL)writeKeychainWithIdentifier:(NSString *)identifier data:(NSData *)data;

+ (NSData *)keychainItemPersistentRefWithIdentifier:(NSString *)identifier;
+ (NSData *)keychainItemDataWithIdentifier:(NSString *)identifier;

+ (BOOL)deleteKeychainItemWithIdentifier:(NSString *)identifier;

@end

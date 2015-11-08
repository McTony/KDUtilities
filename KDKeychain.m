//
//  Keychain.m
//  Netpas
//
//  Created by Blankwonder on 3/26/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import "KDKeychain.h"
#import "KDLogger.h"

@implementation KDKeychain

static NSString *__keychainIdentifier;
static NSString *__keychainAccessGroup;


+ (void)initialize {
    __keychainIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}

+ (void)setKeychainIdentifier:(NSString *)keychainIdentifier {
    __keychainIdentifier = keychainIdentifier;
}

+ (void)setKeychainAccessGroup:(NSString *)keychainAccessGroup {
    __keychainAccessGroup = keychainAccessGroup;
}

+ (NSMutableDictionary *)baseQueryWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *query = [@{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService: __keychainIdentifier} mutableCopy];

    if (__keychainAccessGroup) {
        query[(__bridge id)kSecAttrAccessGroup] = __keychainAccessGroup;
    }
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    query[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    query[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    
    return query;
}

+ (BOOL)writeKeychainWithIdentifier:(NSString *)identifier data:(NSData *)data {
    NSMutableDictionary *query = [self baseQueryWithIdentifier:identifier];
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL) == noErr) {
        OSStatus result = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)@{(__bridge id)kSecValueData: data});
        KDClassLog(@"Update the keychain item result: %d", result);
        
        return result == noErr;
    } else {
        query[(__bridge id)kSecValueData] = data;
        
        OSStatus result = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        KDClassLog(@"Add the keychain item result: %d", result);
        
        return result == noErr;
    }
}

+ (NSData *)keychainItemPersistentRefWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *query = [self baseQueryWithIdentifier:identifier];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnPersistentRef] = (__bridge id)kCFBooleanTrue;
    
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    return (__bridge_transfer NSData *)result;
}

+ (NSData *)keychainItemDataWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *query = [self baseQueryWithIdentifier:identifier];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    
    NSLog(@"%@", query);
    
    CFTypeRef result = NULL;
    OSStatus resultStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (resultStatus != noErr && resultStatus != errSecItemNotFound) {
        KDClassLog(@"Error occurred when read keychian item: %d", resultStatus);
    }
    
    return (__bridge_transfer NSData *)result;
}

+ (BOOL)deleteKeychainItemWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *query = [self baseQueryWithIdentifier:identifier];
    
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)query);
    if (result != noErr) {
        KDClassLog(@"Error occurred when delete keychian item: %d", result);
    }
    
    return result == noErr;
}



@end

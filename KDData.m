//
//  DataModel.m
//  koudaixiang
//
//  Created by Blankwonder on 5/28/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import "KDData.h"
#import "KDLogger.h"
#import "KDUtilities.h"

NSString* const KDDataThreadDictionaryContextKey = @"KDDataThreadDictionaryContextKey";

@implementation KDData

- (id)initWithDatabasePath:(NSURL *)pathURL
               objectModel:(NSManagedObjectModel *)managedObjectModel
    automaticResetDatabase:(BOOL)automaticResetDatabase
{
    KDAssertRequireMainThread();
    
    self = [self init];
    if (!self) 
        return nil;

    if (!managedObjectModel) {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    _databaseURL = [pathURL copy];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    NSError *error = [self addPersistentStore];
    if (error || !_persistentStore) {
        if (automaticResetDatabase) {
            KDClassLog(@"Trying to reset database");
            [[NSFileManager defaultManager] removeItemAtURL:_databaseURL error:nil];
            NSError *error = [self addPersistentStore];
            if (error || !_persistentStore) {
                return nil;
            }
        } else {
            return nil;
        }
    }

    _defaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_defaultContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    [_defaultContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    ([NSThread currentThread].threadDictionary)[KDDataThreadDictionaryContextKey] = _defaultContext;

    _asyncCoreDataOperationQueue = dispatch_queue_create("kdutilities.kddata.context.asyncoperationqueue", NULL);

    return self;
}

- (NSError *)addPersistentStore {
    NSError *error;
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:_databaseURL
                                                                       options:nil
                                                                         error:&error];
    if (error || !_persistentStore) {
        KDClassLog(@"Error occered when add persistent store: %@", [error localizedDescription]);
    }

    return error;
}

- (NSManagedObjectContext *)context_MainThread {
    KDAssertRequireMainThread();
    
    return _defaultContext;
}

- (void)asyncOperation:(KDDataAsyncOperationBlock)operationBlock
         completeBlock:(KDDataAsyncOperationCompleteBlock)completeBlock {
    dispatch_async(_asyncCoreDataOperationQueue ,^{
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setParentContext:_defaultContext];
        ([NSThread currentThread].threadDictionary)[KDDataThreadDictionaryContextKey] = context;

        operationBlock(context);

        BOOL changed = [context hasChanges];
        if (changed) {
#ifdef DEBUG
            NSSet *insertedObjects = [context insertedObjects];
            NSSet *updatedObjects = [context updatedObjects];
            NSSet *deletedObjects = [context deletedObjects];

            KDClassLog(@"Context changed, saving...");
            if (insertedObjects.count > 0) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (NSManagedObject *obj in insertedObjects) {
                    NSString *key = NSStringFromClass([obj class]);
                    int counter = [dic[key] intValue];
                    dic[key] =@(counter + 1);
                }
                KDClassLog(@"Insert: %@", dic);
            }

            if (updatedObjects.count > 0) {
                for (NSManagedObject *obj in updatedObjects) {
                    NSMutableString *log = [NSMutableString stringWithFormat:@"Update: %@", NSStringFromClass([obj class])];
                    NSArray *relationships = obj.entity.relationshipsByName.allKeys;
                    [[obj changedValues] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if (![relationships containsObject:key]) {
                            [log appendFormat:@"\n    (Property)%@ = %@", key, obj];
                        } else {
                            [log appendFormat:@"\n    (Relationship)%@", key];
                        }
                    }];
                    KDClassLog(@"%@", log);
                }
            }

            if (deletedObjects.count > 0) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (NSManagedObject *obj in deletedObjects) {
                    NSString *key = NSStringFromClass([obj class]);
                    int counter = [dic[key] intValue];
                    dic[key] =@(counter + 1);
                }
                KDClassLog(@"Delete: %@", dic);
            }
#endif
            NSError *error = nil;
            if (![context save:&error]) {
                KDClassLog(@"Error occered when save context %@", [error localizedDescription]);
            }
        }

        [[NSThread currentThread].threadDictionary removeObjectForKey:KDDataThreadDictionaryContextKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            if (![_defaultContext save:&error]) {
                KDClassLog(@"Error occered when save context %@", [error localizedDescription]);
            }
            if (completeBlock) {
                completeBlock(changed);
            }
        });
    });
}

- (void)dealloc {
    if ([NSThread mainThread].threadDictionary[KDDataThreadDictionaryContextKey] == _defaultContext) {
        [[NSThread mainThread].threadDictionary removeObjectForKey:KDDataThreadDictionaryContextKey];
    }
}

@end

extern NSSet * KDDataSetManagedObjectProperty(NSManagedObject *object, NSDictionary *newProperty) {
    NSMutableSet *changedProperties = [NSMutableSet set];
    [newProperty enumerateKeysAndObjectsUsingBlock:^(NSString *key, id newValue, BOOL *stop) {
        id oldValue = [object valueForKey:key];
        if (![oldValue isEqual:newValue] &&
            !(newValue == [NSNull null] && oldValue == nil)) {
            if (newValue != [NSNull null]) {
                [object setValue:newValue forKey:key];
            } else {
                [object setValue:nil forKey:key];
            }
            [changedProperties addObject:key];
        }
    }];
    return [NSSet setWithSet:changedProperties];
}

extern NSArray *KDDataFetchManagedObject(NSString *objectModelName, NSPredicate *predicate) {
    return KDDataFetchManagedObjectSort(objectModelName, predicate, nil, NO);
}

extern NSArray *KDDataFetchManagedObjectSort(NSString *objectModelName, NSPredicate *predicate, NSString *sortKey, BOOL sortAscending) {
    NSManagedObjectContext *context = KDDataCurrentThreadContext();
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    if (sortKey) {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sortKey
                                                                         ascending:sortAscending]]];
    }
	[fetchRequest setEntity:[NSEntityDescription entityForName:objectModelName
	                                    inManagedObjectContext:context]];
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {
		KDLog(@"KDData", @"Error occered: %@", error);
		return nil;
	}
	return result;
}

//
//  DataModel.h
//  koudaixiang
//
//  Created by Blankwonder on 5/28/11.
//  Copyright 2011 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^KDDataAsyncOperationCompleteBlock)(BOOL changed);
typedef void (^KDDataAsyncOperationBlock)(NSManagedObjectContext *context);

extern NSString* const KDDataThreadDictionaryContextKey;

@interface KDData : NSObject {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSPersistentStore *_persistentStore;
    NSURL *_databaseURL;
    
    NSManagedObjectContext *_defaultContext;
    
    dispatch_queue_t _asyncCoreDataOperationQueue;
}

- (id)initWithDatabasePath:(NSURL *)pathURL
               objectModel:(NSManagedObjectModel *)managedObjectModel
    automaticResetDatabase:(BOOL)automaticResetDatabase;

- (NSManagedObjectContext *)context_MainThread;

- (void)asyncOperation:(KDDataAsyncOperationBlock)operationBlock
         completeBlock:(KDDataAsyncOperationCompleteBlock)completeBlock;

@end

extern NSSet * KDDataSetManagedObjectProperty(NSManagedObject *object, NSDictionary *newProperty);

NS_INLINE NSManagedObjectContext *KDDataCurrentThreadContext()
{ return [[NSThread currentThread] threadDictionary][KDDataThreadDictionaryContextKey]; }

extern NSArray *KDDataFetchManagedObject(NSString *objectModelName, NSPredicate *predicate);
extern NSArray *KDDataFetchManagedObjectSort(NSString *objectModelName, NSPredicate *predicate, NSString *sortKey, BOOL sortAscending) ;

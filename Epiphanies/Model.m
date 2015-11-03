//
//  Model.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Model.h"
#import "AppDelegate.h" // import here so that classes that import the model won't import that AppDelegate?

@implementation Model

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _container = [CKContainer defaultContainer];
        _database = [_container privateCloudDatabase];
        
        [self createZoneAssignZoneID];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = [appDelegate managedObjectContext];
        
    }
    return self;
}

#pragma mark - Zone Saver

// TESTED
- (void) createZoneAssignZoneID {
    [ZoneCreator createCustomZoneForDatabase:_database withCompletionHandler:^(NSArray *zoneSaves, NSArray *zoneDeletes, NSError *errorZone) {
        if (zoneSaves == nil && zoneDeletes == nil && errorZone == nil) { // zone already created
            return;
        } else if (errorZone) {
            NSLog(@"Better error handling than this %@", errorZone.description);
        }
        else {
            CKRecordZone *zoneCreated = zoneSaves[0];
            _zoneId = zoneCreated.zoneID;
            [SubscriptionCreator addSubscriptionsToDatabase:_database withCompletionHandler:^(BOOL success, NSError *errorSubscription) {
                // if success == no and error = nil, the subscription was already saved for this device
                if (!success && !errorSubscription) {
                    NSLog(@"The subscription was already saved");
                } else if (errorSubscription) {
                    NSLog(@"better error handling than this subscription error: %@", errorSubscription.description);
                }
            }];
        }
    }];
}

#pragma mark - Entire Record Savers

-(void) saveCollections: (nonnull NSArray<Collection *> *) collections
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [Saver saveObjects:collections withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [Saver saveContext:_context];
    
}

-(void) saveThoughts:(nonnull NSArray<Thought *> *)thoughts withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    NSArray<id<FunObject>> *thoughtsAndPhotos = [Saver flattenThoughtsAndPhotos:thoughts];
    
    CKModifyRecordsOperation *operationSaveRecords = [Saver saveObjects:thoughtsAndPhotos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [Saver saveContext:_context];
    
}

-(void) savePhotos:(nonnull NSArray<Photo *> *)photos withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [Saver saveObjects:photos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [Saver saveContext:_context];
    
}

// TESTED
-(void)saveObjects:(nonnull NSArray<id<FunObject>> *)objects withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [Saver saveObjects:objects withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
//    [Saver saveContext:_context];
}

#pragma mark - Portion of Record Saver

-(void) saveObject:(nonnull id<FunObject>)object withChanges:(nonnull NSDictionary *)dictionaryOfChanges withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSavePartialRecord = [Saver saveObject:object withChanges:dictionaryOfChanges withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSavePartialRecord];
    
    [Saver saveContext:_context];
}

#pragma mark - Order of Record Savers

-(void) saveOrderOfObjects:(nonnull NSArray<id<FunObject, Orderable>> *)objectsOfSameType withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    // order the objects based on relative placement
    NSArray *orderedObjects = [Orderer correctPlacementBasedOnOrderInArray:objectsOfSameType];
    
    // get record references for each object with only the new change of placement
    NSMutableArray *records = [NSMutableArray new];
    for (id<FunObject, Orderable> object in orderedObjects) {
        CKRecord *record = [object asRecordWithChanges:@{PLACEMENT_KEY : object.placement}];
        [records addObject:record];
    }
    
    // save those records
    CKModifyRecordsOperation *operationSaveObjects = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete:nil];
    
    // set the qualityOfService (priority of this operation)
    operationSaveObjects.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    
    // handle the user's blocks
    operationSaveObjects.perRecordProgressBlock = perRecordProgressBlock;
    operationSaveObjects.perRecordCompletionBlock = perRecordCompletionBlock;
    operationSaveObjects.modifyRecordsCompletionBlock = modifyRecordsCompletionBlock;
    
    [_database addOperation:operationSaveObjects];

    [Saver saveContext:_context];
    
}

-(void) saveCoreDataContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

#pragma mark - Fetchers

-(void) reloadWithCompletion:(void (^)(NSArray<Collection *> *, NSError *))block {
    
//    // the arrays to fill with fetched objects
    __block NSMutableArray<Collection *> *collectionsFetched = [NSMutableArray new];
//    __block NSMutableArray<Thought *> *thoughtsFetched = [NSMutableArray new];
    
    // the block executed after each collection is fetched
    void (^collectionRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        Collection *collection = (Collection *)[self refreshManagedObjectBasedOnRecord:record];
        [collectionsFetched addObject:collection];
    };
    
    // the block executed after each thought is fetched -- due to dependancy, called after the collection operation has completed
    void (^thoughtRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentCollectionReference = [record objectForKey:PARENT_COLLECTION_KEY];
        CKRecordID *parentCollectionId = parentCollectionReference.recordID;
        
        Thought *thought = (Thought *)[self refreshManagedObjectBasedOnRecord:record];
    };
    
    // the block executed after each Photo is fetched -- due to dependancy, called after the thought operation has completed
    void (^photoRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentThoughtReference = [record objectForKey:PARENT_THOUGHT_KEY];
        CKRecordID *parentThoughtId = parentThoughtReference.recordID;
        
        Photo *photo = (Photo *)[self refreshManagedObjectBasedOnRecord:record];
    };
    
    // the block executed after the Collection & Thought operations has completed
    void (^queryCompletionBlock)(CKQueryCursor *cursor, NSError *operationError) = ^void(CKQueryCursor *cursor, NSError *operationError) {
        if (cursor) NSLog(@"Handle cursor: %@", cursor.description);
        if (operationError) NSLog(@"Error fetching: %@", operationError.description);
    };
    
    // the block executed after the Photo operation has completed (all operations completed)
    void (^finallyBlock)(CKQueryCursor *operationPhotoCursor, NSError *operationPhotoError) = ^void(CKQueryCursor *operationPhotoCursor, NSError *operationPhotoError) {
        if (operationPhotoCursor) NSLog(@"Handle cursor: %@", operationPhotoCursor.description);
        if (operationPhotoError) NSLog(@"Error fetching: %@", operationPhotoError.description);
        
        // pass the results of the fetch into the populatedCollection array found in the block
        block(collectionsFetched, nil);
    };
    
    // operations to populate the objectFetched arrays
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQueryOperation *operationFetchCollections = [Fetcher operationFetchRecordsOfType:COLLECTION_RECORD_TYPE predicate:predicate
                                                        withRecordFetchedBlock:collectionRecordFetchedBlock
                                                      withQueryCompletionBlock:queryCompletionBlock];
    CKQueryOperation *operationFetchThoughts = [Fetcher operationFetchRecordsOfType:THOUGHT_RECORD_TYPE predicate:predicate
                                                     withRecordFetchedBlock:thoughtRecordFetchedBlock
                                                   withQueryCompletionBlock:queryCompletionBlock];
    CKQueryOperation *operationFetchPhotos = [Fetcher operationFetchRecordsOfType:PHOTO_RECORD_TYPE predicate:predicate
                                                   withRecordFetchedBlock:photoRecordFetchedBlock
                                                 withQueryCompletionBlock:finallyBlock];
    
    // add dependancies to make sure that Collections are fetched first, then Thoughts, then Photos
    [operationFetchThoughts addDependency:operationFetchCollections];
    [operationFetchPhotos addDependency:operationFetchThoughts];
    
    // execute operations
    [_database addOperation:operationFetchCollections];
    [_database addOperation:operationFetchThoughts];
    [_database addOperation:operationFetchPhotos];
}

-(void) fetchCKRecordAndUpdateCoreData:(nonnull CKRecordID *)recordId {
    [Fetcher fetchCKRecordAndUpdateCoreData:recordId fromDatabase:_database inContext:_context];
}

-(id<FunObject>) refreshManagedObjectBasedOnRecord: (nonnull CKRecord *) record {
    return [Fetcher refreshManagedObjectBasedOnRecord:record inContext:_context];
}

#pragma mark - Deletion

-(void) deleteFromBothCloudKitAndCoreData: (nonnull id<FunObject>) object {
    [self deleteObjectFromCloudKit:object completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error deleting: %@", error.description);
        } else {
            [self deleteObjectFromCoreData:object];
        }
    }];
}

-(void) deleteObjectFromCloudKit: (id<FunObject>) object completionHandler:(void(^)(NSError *error))block {
    
    [Deleter deleteObjectFromCloudKit:object onDatabase:_database withCompletionHandler:^(CKRecordID *deletedId, NSError *error) {
        block(error);
    }];
}

-(void) deleteObjectFromCoreData: (id<FunObject>) object {
    [Deleter deleteObject:object context:_context];
}

-(void) deleteObjectFromCoreDataWithRecordId: (nonnull CKRecordID *) recordId withType: (nonnull NSString *) type {
    [Deleter deleteObjectWithRecordId:recordId context:_context type:type];
}

#pragma mark - Utilities

- (void) clearUserDefautls {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void) executeContainerOperation: (nonnull CKOperation *) operation {
    [_container addOperation:operation];
}

@end

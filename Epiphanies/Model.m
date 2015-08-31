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
        
        _fetcher = [[Fetcher alloc] init];
        _saver = [[Saver alloc] init];
        _deleter = [[Deleter alloc] init];
        
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
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:collections withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [self saveCoreDataContext];
    
}

-(void) saveThoughts:(nonnull NSArray<Thought *> *)thoughts withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    NSArray<id<FunObject>> *thoughtsAndPhotos = [_saver flattenThoughtsAndPhotos:thoughts];
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:thoughtsAndPhotos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [self saveCoreDataContext];
    
}

-(void) savePhotos:(nonnull NSArray<Photo *> *)photos withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:photos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [self saveCoreDataContext];
    
}

// TESTED
-(void)saveObjects:(nonnull NSArray<id<FunObject>> *)objects withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:objects withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
    [self saveCoreDataContext];
}

#pragma mark - Portion of Record Saver

-(void) saveObject:(nonnull id<FunObject>)object withChanges:(nonnull NSDictionary *)dictionaryOfChanges withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSavePartialRecord = [_saver saveObject:object withChanges:dictionaryOfChanges withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSavePartialRecord];
    
    [self saveCoreDataContext];
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

    [self saveCoreDataContext];
    
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
        Collection *collection = (Collection *)[self refreshObjectBasedOnRecord:record];
        [collectionsFetched addObject:collection];
    };
    
    // the block executed after each thought is fetched -- due to dependancy, called after the collection operation has completed
    void (^thoughtRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentCollectionReference = [record objectForKey:PARENT_COLLECTION_KEY];
        CKRecordID *parentCollectionId = parentCollectionReference.recordID;
        
        Thought *thought = (Thought *)[self refreshObjectBasedOnRecord:record];
        [self findParentAndUpdateRelationship:thought parentId:parentCollectionId];
        
//        // find the Collection in the collectionsFetched array that has that recordId
//        for (Collection *collection in collectionsFetched) { // b/c of operation dependancies and block variables, collectionsFetched still has contents!!!!
//            CKRecordID *collectionRecordId = collection.recordId;
//            if ([collectionRecordId isEqual:parentCollectionId]) {
//                Thought *thought = (Thought *)[self refreshObjectBasedOnRecord:record];
//                [thoughtsFetched addObject:thought];
//                [collection addThoughtsObject:thought];
//                break;
//            }
//        }
    };
    
    // the block executed after each Photo is fetched -- due to dependancy, called after the thought operation has completed
    void (^photoRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentThoughtReference = [record objectForKey:PARENT_THOUGHT_KEY];
        CKRecordID *parentThoughtId = parentThoughtReference.recordID;
        
        Photo *photo = (Photo *)[self refreshObjectBasedOnRecord:record];
        [self findParentAndUpdateRelationship:photo parentId:parentThoughtId];
        
//        // find the Thought in the thoughtsFetched array that has that recordId
//        for (Thought *thought in thoughtsFetched) {
//            CKRecordID *thoughtRecordId = thought.recordId;
//            if ([thoughtRecordId isEqual:parentThoughtId]) {
//                photo.parentThought = thought;
//                [thought addPhotosObject:photo];  // populate the thought.photos array with the current photo (save a step by not having to go back up the tree)
//                break;
//            }
//            // TODO - handle if no parent was found
//        }
        
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
    CKQueryOperation *operationFetchCollections = [_fetcher operationFetchRecordsOfType:COLLECTION_RECORD_TYPE predicate:predicate
                                                        withRecordFetchedBlock:collectionRecordFetchedBlock
                                                      withQueryCompletionBlock:queryCompletionBlock];
    CKQueryOperation *operationFetchThoughts = [_fetcher operationFetchRecordsOfType:THOUGHT_RECORD_TYPE predicate:predicate
                                                     withRecordFetchedBlock:thoughtRecordFetchedBlock
                                                   withQueryCompletionBlock:queryCompletionBlock];
    CKQueryOperation *operationFetchPhotos = [_fetcher operationFetchRecordsOfType:PHOTO_RECORD_TYPE predicate:predicate
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

// TESTED
-(void) refreshObjectWithRecordId:(nonnull CKRecordID *)recordId {
    
    // fetch the updated record from cloud kit
    [_database fetchRecordWithID:recordId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error fetching from cloud kit: %@", error.description);
        } else {
            if (record) {
                [self refreshObjectBasedOnRecord:record];
            } else {
                NSLog(@"No records were found");
            }
        }
    }];
}

-(id<FunObject>) refreshObjectBasedOnRecord: (nonnull CKRecord *) record {
    
    // fetch the old record from core data
    NSString *type = record.recordType;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@",record[OBJECT_ID_KEY]];
    NSArray *fetchedObjects = [_fetcher fetchRecordsFromCoreDataContext:_context type:type predicate:predicate sortDescriptiors:nil];
    
    // if there was no error
    if (fetchedObjects != nil) {
        
        id<FunObject> objectToReturn;
        
        // if an object was found, udpate the existing object with the new information
        if ([fetchedObjects count]) {
            
            [fetchedObjects[0] updateBasedOnCKRecord:record];
            objectToReturn = fetchedObjects[0];
            
        } else { // no object was found that matches this record id. Add an object that reperesents this record to core data
            
            if ([type isEqualToString:COLLECTION_RECORD_TYPE]) {
                objectToReturn = [Collection newManagedObjectInContext:_context basedOnCKRecord:record];
            } else if ([type isEqualToString:THOUGHT_RECORD_TYPE]) {
                objectToReturn = [Thought newManagedObjectInContext:_context basedOnCKRecord:record];
            } else if ([type isEqualToString:PHOTO_RECORD_TYPE]) {
                objectToReturn = [Photo newManagedObjectInContext:_context basedOnCKRecord:record];
            } else {
                NSLog(@"Incorrect type");
            }
            
        }
        
        // update the relationship between the child and it's possible parent
        if ([record objectForKey:PARENT_COLLECTION_KEY]) { // record is a thought
            
            // get this thought's parent recordId
            CKReference *parentCollectionReference = [record objectForKey:PARENT_COLLECTION_KEY];
            CKRecordID *parentCollectionId = parentCollectionReference.recordID;

            // update parent relationship
            [self findParentAndUpdateRelationship:(id<Child>)objectToReturn parentId:parentCollectionId];
            
        } else if ([record objectForKey:PARENT_THOUGHT_KEY]) { // record is a Photo
            
            // get this photo's parent recordId
            CKReference *parentThoughtReference = [record objectForKey:PARENT_THOUGHT_KEY];
            CKRecordID *parentThoughtId = parentThoughtReference.recordID;
            
            // update parent relationship
            [self findParentAndUpdateRelationship:(id<Child>)objectToReturn parentId:parentThoughtId];

        }
        
        [self saveCoreDataContext];
        return objectToReturn;
    } else {
        NSLog(@"error fetching objects from core data");
        return nil;
    }

}

-(void) findParentAndUpdateRelationship: (id<Child>) child parentId: (CKRecordID *) parentId {
    
    // get the recordType of the parent
    NSString *parentType;
    if ([child isMemberOfClass:[Thought class]]) {
        parentType = COLLECTION_RECORD_TYPE;
    } else { // photo object
        parentType = THOUGHT_RECORD_TYPE;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", RECORD_ID_KEY, parentId];
    NSArray *objects = [_fetcher fetchRecordsFromCoreDataContext:_context type:parentType predicate:predicate sortDescriptiors:nil];
    
    // update the relationship between the child and the found parent
    if ([parentType isEqualToString:COLLECTION_RECORD_TYPE]) {
        
        Thought *childThought = (Thought *) child;
        Collection *parentCollection = (Collection *) objects[0];
        childThought.parentCollection = parentCollection;
        [parentCollection addThoughtsObject:childThought];
        
    } else {
        
        Photo *childPhoto = (Photo *) child;
        Thought *parentThought = (Thought *) objects[0];
        childPhoto.parentThought = parentThought;
        [parentThought addPhotosObject:childPhoto];
        
    }
}

#pragma mark - Deletion

-(void) deleteObjectFromCloudKit: (id<FunObject>) object completionHandler:(void(^)(NSError *error))block {
    
    // if the object is a child, remove it from it's parent's array of children
    if ([object respondsToSelector:@selector(removeFromParent)]) {
        id<Child> child = (id<Child>) object;
        [child removeFromParent];
    }
    
    // delete the object from the database - because of the way CKReferences are set up, the child objects in the database will be deleted as well
    [_deleter deleteRecord:object.recordId onDatabase:_database withCompletionHandler:^(CKRecordID *deletedId, NSError *error) {
        block(error);
    }];
}

-(void) deleteObjectFromCoreData: (id<FunObject>) object {
    [_context deleteObject:object];
}

-(void) deleteObjectFromCoreDataWithRecordId: (nonnull CKRecordID *) recordId withType: (nonnull NSString *) type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %@", RECORD_ID_KEY, recordId];
    NSArray *objects = [_fetcher fetchRecordsFromCoreDataContext:_context type:type predicate:predicate sortDescriptiors:nil];
    [self deleteObjectFromCoreData:objects[0]];
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

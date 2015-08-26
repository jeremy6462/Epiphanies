//
//  Model.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Model.h"

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
        
    }
    return self;
}

#pragma mark - Zone Saver

// TESTED
- (void) createZoneAssignZoneID {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
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

-(void) saveCollectionsToCloudKit: (nonnull NSArray<Collection *> *) collections
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:collections withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
}

-(void) saveThoughtsToCloudKit:(nonnull NSArray<Thought *> *)thoughts withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    NSArray<id<FunObject>> *thoughtsAndPhotos = [_saver flattenThoughtsAndPhotos:thoughts];
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:thoughtsAndPhotos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
}

-(void) savePhotosToCloudKit:(nonnull NSArray<Photo *> *)photos withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:photos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
}

// TESTED
-(void)saveObjectsToCloudKit:(nonnull NSArray<id<FunObject>> *)objects withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:objects withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
}

#pragma mark - Portion of Record Saver

-(void) saveObjectToCloudKit:(nonnull id<FunObject>)object withChanges:(nonnull NSDictionary *)dictionaryOfChanges withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSavePartialRecord = [_saver saveObject:object withChanges:dictionaryOfChanges withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSavePartialRecord];
}

#pragma mark - Order of Record Savers

-(void) saveOrderOfObjects:(nonnull NSArray<id<FunObject, Orderable>> *)objectsOfSameType withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nullable void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    // order the objects based on relative placement
    NSArray *orderedObjects = [Orderer orderObjectsBasedOnPlacementInArray:objectsOfSameType];
    
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

}

#pragma mark - Fetchers

// THIS CODE ACTUALLY WORKS!!! All of the block arrays will keep their values and we actually pass back a collection array through the block. TODO - test taking out the block
// TESTED

// QUESTION - will this fetch from the custom databse (or all of the databse?)
-(void) reloadWithCompletion:(void (^)(NSArray<Collection *> *, NSError *))block {
    
    // the arrays to fill with fetched objects
    __block NSMutableArray<Collection *> *collectionsFetched = [NSMutableArray new];
    __block NSMutableArray<Thought *> *thoughtsFetched = [NSMutableArray new];
    
    // the block executed after each collection is fetched
    void (^collectionRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        Collection *collection = [[Collection alloc] initWithRecord:record];
        [collectionsFetched addObject:collection];
    };
    
    // the block executed after each thought is fetched -- due to dependancy, called after the collection operation has completed
    void (^thoughtRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentCollectionReference = [record objectForKey:PARENT_COLLECTION_KEY];
        CKRecordID *parentCollectionId = parentCollectionReference.recordID;
        
        // find the Collection in the collectionsFetched array that has that recordId
        for (Collection *collection in collectionsFetched) { // b/c of operation dependancies and block variables, collectionsFetched still has contents!!!!
            CKRecordID *collectionRecordId = collection.recordId;
            if ([collectionRecordId isEqual:parentCollectionId]) {
                Thought *thought = [[Thought alloc] initWithRecord:record collection:collection];
                [thoughtsFetched addObject:thought];
                collection.thoughts = [collection.thoughts arrayByAddingObject:thought];
                break;
            }
            // TODO - handle if no parent was found
        }
    };
    
    // the block executed after each Photo is fetched -- due to dependancy, called after the thought operation has completed
    void (^photoRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentThoughtReference = [record objectForKey:PARENT_THOUGHT_KEY];
        CKRecordID *parentThoughtId = parentThoughtReference.recordID;
        
        Photo *photo = [[Photo alloc] initWithRecord:record];
        
        // find the Thought in the thoughtsFetched array that has that recordId
        for (Thought *thought in thoughtsFetched) {
            CKRecordID *thoughtRecordId = thought.recordId;
            if ([thoughtRecordId isEqual:parentThoughtId]) {
                photo.parentThought = thought;
                thought.photos = [thought.photos arrayByAddingObject:photo]; // populate the thought.photos array with the current photo (save a step by not having to go back up the tree)
                break;
            }
            // TODO - handle if no parent was found
        }
        
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
    CKQueryOperation *operationFetchCollections = [_fetcher fetchAllRecordType:COLLECTION_RECORD_TYPE
                                                        withRecordFetchedBlock:collectionRecordFetchedBlock
                                                      withQueryCompletionBlock:queryCompletionBlock];
    CKQueryOperation *operationFetchThoughts = [_fetcher fetchAllRecordType:THOUGHT_RECORD_TYPE
                                                     withRecordFetchedBlock:thoughtRecordFetchedBlock
                                                   withQueryCompletionBlock:queryCompletionBlock];
    CKQueryOperation *operationFetchPhotos = [_fetcher fetchAllRecordType:PHOTO_RECORD_TYPE
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

// TODO - if fetching just a parent, will still have to feth all children
-(void) fetchRecordWithId:(nonnull CKRecordID *)recordId withRecordType:(NSString *)type withRecordFetchedBlock:(void (^)(CKRecord *))recordFetchedBlock withQueryCompletionBlock:(void (^)(CKQueryCursor * _Nullable, NSError * _Nullable))queryCompletionBlock {
    
    // NSPredicate to request a record with that Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordId == %@",recordId]; // TODO - make sure recordId is the correct key
    
    CKQueryOperation *operationFetchRecord = [_fetcher fetchRecordsOfType:type predicate:predicate withRecordFetchedBlock:recordFetchedBlock withQueryCompletionBlock:queryCompletionBlock];
    
    [_database addOperation:operationFetchRecord];
}

#pragma mark - Deletion

-(void) deleteObject: (id<FunObject>) object completionHandler:(void(^)(NSError *error))block {
    
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

@end

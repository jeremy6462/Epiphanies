//
//  Model.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Model.h"

@implementation Model

- (instancetype)init
{
    self = [super init];
    if (self) {
        _container = [CKContainer defaultContainer];
        _database = [_container privateCloudDatabase];
        
        _fetcher = [[Fetcher alloc] init];
        _saver = [[Saver alloc] init];
        _deleter = [[Deleter alloc] init];
        
    }
    return self;
}

#pragma mark - Zone Saver

- (void) createZoneAssignZoneID {
    [ZoneCreator createCustomZoneForDatabase:_database withCompletionHandler:^(NSArray *zoneSaves, NSArray *zoneDeletes, NSError *error) {
        if (error) {
            NSLog(@"Better error handling than this %@", error.description);
        } else {
            CKRecordZone *zoneCreated = zoneSaves[0];
            _zoneId = zoneCreated.zoneID;
            [SubscriptionCreator addSubscriptionsToDatabase:_database withCompletionHandler:^(BOOL success, NSError *error) {
                NSLog(@"Error saving subscription to database: %@", error.description);
            }];
        }
    }];

}

#pragma mark - Entire Record Savers

-(void) saveCollectionsToCloudKit: (nonnull NSArray<Collection *> *) collections
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:collections withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
}

-(void) saveThoughtsToCloudKit:(nonnull NSArray<Thought *> *)thoughts withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nonnull void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    NSArray<id<FunObject>> *thoughtsAndPhotos = [_saver flattenThoughtsAndPhotos:thoughts];
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:thoughtsAndPhotos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
}

-(void) savePhotosToCloudKit:(nonnull NSArray<Photo *> *)photos withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nonnull void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:photos withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
    
}

-(void)saveObjectsToCloudKit:(nonnull NSArray<id<FunObject>> *)objects withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nonnull void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSaveRecords = [_saver saveObjects:objects withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSaveRecords];
}

#pragma mark - Portion of Record Saver

-(void) saveObjectToCloudKit:(nonnull id<FunObject>)object withChanges:(nonnull NSDictionary *)dictionaryOfChanges withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nonnull void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
    CKModifyRecordsOperation *operationSavePartialRecord = [_saver saveObject:object withChanges:dictionaryOfChanges withPerRecordProgressBlock:perRecordProgressBlock withPerRecordCompletionBlock:perRecordCompletionBlock withCompletionBlock:modifyRecordsCompletionBlock];
    
    [_database addOperation:operationSavePartialRecord];
}

#pragma mark - Order of Record Savers

-(void) saveOrderOfObjects:(nonnull NSArray<id<FunObject, Orderable>> *)objectsOfSameType withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nonnull void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock {
    
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

-(void) reloadWithCompletion:(void (^)(NSArray<Collection *> *, NSError *))block {
    
    // the arrays to fill with fetched objects
    NSMutableArray<Collection *> *collectionsFetched = [NSMutableArray new];
    NSMutableArray<Thought *> *thoughtsFetched = [NSMutableArray new];
    NSMutableArray<Photo *> *photosFetched = [NSMutableArray new];
    
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
        
        Collection *parent;
        
        // find the Collection in the collectionsFetched array that has that recordId
        for (Collection *collection in collectionsFetched) {
            CKRecordID *collectionRecordId = collection.recordId;
            if ([collectionRecordId isEqual:parentCollectionId]) {
                parent = collection;
                break;
            }
            // TODO - handle if no parent was found
        }
        
        Thought *thought = [[Thought alloc] initWithRecord:record collection:parent];
        [thoughtsFetched addObject:thought];
    };
    
    // the block executed after each thought is fetched -- due to dependancy, called after the thought operation has completed
    void (^photoRecordFetchedBlock)(CKRecord *record) = ^void(CKRecord *record) {
        
        // get this thought's parent recordId
        CKReference *parentThoughtReference = [record objectForKey:PARENT_THOUGHT_KEY]; // TODO - check to see if parentThoughtReference is fully populated (fetched full tree (Thought + Collection hierary)) - if so, then only need to fetch photos and can take a part the tree from each fetch
        CKRecordID *parentThoughtId = parentThoughtReference.recordID;
        
        Photo *photo = [[Photo alloc] initWithRecord:record];
        
        // find the Collection in the collectionsFetched array that has that recordId
        for (Thought *thought in thoughtsFetched) {
            CKRecordID *thoughtRecordId = thought.recordId;
            if ([thoughtRecordId isEqual:parentThoughtId]) {
                photo.parentThought = thought;
                thought.photos = [thought.photos arrayByAddingObject:photo]; // populate the thought.photos array with the current photo (save a step
            }
            // TODO - handle if no parent was found
        }
        
        [photosFetched addObject:photo];
    };
    
    // the block executed after the Collection & Thought operations has completed
    void (^queryCompletionBlock)(CKQueryCursor *cursor, NSError *operationError) = ^void(CKQueryCursor *cursor, NSError *operationError) {
        if (cursor) NSLog(@"Handle cursor: %@", cursor.description);
        if (operationError) NSLog(@"Error fetching: %@", operationError.description);
    };
    
    // the block executed after the Photo operation has completed (all operations completed)
    void (^finalyBlock)(CKQueryCursor *operationPhotoCursor, NSError *operationPhotoError) = ^void(CKQueryCursor *operationPhotoCursor, NSError *operationPhotoError) {
        if (operationPhotoCursor) NSLog(@"Handle cursor: %@", operationPhotoCursor.description);
        if (operationPhotoError) NSLog(@"Error fetching: %@", operationPhotoError.description);
        
        // create the hierarchy for each collection - organize each Thought (now all populated with Photos) into it's parent collection - didn't do this in thoughtRecordFetchedBlock because objective-c is pass-by-value and not reference. The Thought I would have added to the Collection found in collectionsFetched would have been a copy of the Thought used in thoughtsFetched so if I added a Photo to a Thought in thoughtsFetched the original Thought that was added to a Collection in collectionsFetched would not have an updated value (because it is not a reference to the newly updated Thought in thoughtsFetched)
        for (Thought *thought in thoughtsFetched) {
            for (Collection *collection in collectionsFetched) {
                if ([thought.parentCollection /* == ?*/ isEqual:collection]){
                    collection.thoughts = [collection.thoughts arrayByAddingObject:thought];
                }
            }
            // TODO - handle if no parent was found
        }
        
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
                                                 withQueryCompletionBlock:finalyBlock];
    
    // add dependancies to make sure that Collections are fetched first, then Thoughts, then Photos
    [operationFetchThoughts addDependency:operationFetchCollections];
    [operationFetchPhotos addDependency:operationFetchThoughts];
    
    // execute operations
    [_database addOperation:operationFetchCollections];
    [_database addOperation:operationFetchThoughts];
    [_database addOperation:operationFetchPhotos];
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

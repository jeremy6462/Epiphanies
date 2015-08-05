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
        
        
    }
    return self;
}

- (void) createZoneAssignZoneID {
    [ZoneCreator createCustomZoneForDatabase:_database withCompletionHandler:^(NSArray *zoneSaves, NSArray *zoneDeletes, NSError *error) {
        if (error) {
            NSLog(@"Better error handling than this %@", error.description);
        } else {
            CKRecordZone *zoneCreated = zoneSaves[0];
            _zoneId = zoneCreated.zoneID;
        }
    }];

}

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

@end

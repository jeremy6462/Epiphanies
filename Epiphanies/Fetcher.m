//
//  Fetcher.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/26/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Fetcher.h"
#import "Saver.h"

@implementation Fetcher

#pragma mark - Core Data Fetch

// Fetch Core Data objects
+ (nullable NSArray<id<FunObject>> *) fetchRecordsFromCoreDataContext: (nonnull NSManagedObjectContext *) context type: (nonnull NSString *) recordType predicate: (nonnull NSPredicate *) predicate sortDescriptiors: (nullable NSArray <NSSortDescriptor *> *) sortDescriptors {
    // if recordType is not one of the record types saved to CloudKit, return nil
    if  (![Fetcher supportedRecordType:recordType]) {
        NSLog(@"core data fetch error: Could not fetch a record type that is not supported. Supported record types include Collection, Thought, and Photo");
        return nil;
    }
    
    // a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // set the entity type for the given fetch request
    NSEntityDescription *entity = [NSEntityDescription entityForName:recordType inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // specify criteria for filtering which objects to fetch
    [fetchRequest setPredicate:predicate];
    
    // set the sort descriptors
    if (!sortDescriptors) {
        NSSortDescriptor *placementSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"placement"
                                                                      ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:placementSortDescriptor]];
    } else {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    
    // execute the fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"core data fetch error: %@", error.description);
    }
    return fetchedObjects;
}

// Fetch Cloud Kit record and (fetch &) update Core Data objct
+ (void) fetchCKRecordAndUpdateCoreData:(nonnull CKRecordID *)recordId fromDatabase: (nonnull CKDatabase *) database  inContext: (nonnull NSManagedObjectContext *) context {
    // fetch the updated record from cloud kit
    [Fetcher fetchRecordWithRecordId:recordId fromDatabase:database withCompletionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error fetching from cloud kit: %@", error.description);
        } else {
            if (record) {
                [Fetcher refreshManagedObjectBasedOnRecord:record inContext:context];
            } else {
                NSLog(@"No records were found");
            }
        }
    }];

}

// With Cloud Kit record, (fetch &) update Core Data object
+ (nullable id<FunObject>) refreshManagedObjectBasedOnRecord: (nonnull CKRecord *) record inContext: (nonnull NSManagedObjectContext *) context {
    
    // fetch the old record from core data
    NSString *type = record.recordType;
    NSPredicate *predicate;
    if (record[OBJECT_ID_KEY]) { // used to not through error if there is no objectId key. There should be b/c all records have one
        predicate = [NSPredicate predicateWithFormat:@"objectId == %@",record[OBJECT_ID_KEY]];
    }
    NSArray *fetchedObjects = [Fetcher fetchRecordsFromCoreDataContext:context type:type predicate:predicate sortDescriptiors:nil];
    
    // if there was no error
    if (fetchedObjects != nil) {
        
        id<FunObject> objectToReturn;
        
        // if an object was found, udpate the existing object with the new information
        if ([fetchedObjects count]) {
            
            objectToReturn = fetchedObjects[0];
            [objectToReturn updateBasedOnCKRecord:record];
            
            
        } else { // no object was found that matches this record id. Add an object that reperesents this record to core data
            
            if ([type isEqualToString:COLLECTION_RECORD_TYPE]) {
                objectToReturn = [Collection newManagedObjectInContext:context basedOnCKRecord:record];
            } else if ([type isEqualToString:THOUGHT_RECORD_TYPE]) {
                objectToReturn = [Thought newManagedObjectInContext:context basedOnCKRecord:record];
            } else if ([type isEqualToString:PHOTO_RECORD_TYPE]) {
                objectToReturn = [Photo newManagedObjectInContext:context basedOnCKRecord:record];
            } else {
                NSLog(@"Incorrect type");
                return nil;
            }
            
        }
        
        // get a reference to the parent (if there is one and check if the current parent is different than the record's parent. If it is, update the relationship
        NSString *parentKey;
        if ([record objectForKey:PARENT_COLLECTION_KEY]) { // record is a thought
            parentKey = PARENT_COLLECTION_KEY;
        } else if ([record objectForKey:PARENT_THOUGHT_KEY]) { // record is a Photo
            parentKey = PARENT_THOUGHT_KEY;
        }
        
        if (parentKey) { // if there is a parent
            // get this object's parent recordId
            CKReference *parentReference = [record objectForKey:parentKey];
            CKRecordID *recordParentId = parentReference.recordID;
            
            // update parent relationship
            [Fetcher findParentAndUpdateRelationship:(id<Child>)objectToReturn parentId:recordParentId inContext: context];
        }
        
        // save the context now that it has an updated relationship and
        [Saver saveContext:context];
        
        return objectToReturn;
    } else {
        NSLog(@"error fetching objects from core data");
        return nil;
    }
    
}


// TODO - understand if these update methods are nescessary
// TODO - most of the time this is unnescessary. Refactor so that if old parent == updated record's parent, we don't have to fetch
+ (void) findParentAndUpdateRelationship: (nonnull id<Child>) child parentId: (nonnull CKRecordID *) parentId inContext: (nonnull NSManagedObjectContext *) context {
    
    // get the recordType of the parent
    NSString *parentType;
    if ([child isMemberOfClass:[Thought class]]) {
        parentType = COLLECTION_RECORD_TYPE;
    } else { // photo object
        parentType = THOUGHT_RECORD_TYPE;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", RECORD_NAME_KEY, parentId.recordName];
    NSArray *objects = [Fetcher fetchRecordsFromCoreDataContext:context type:parentType predicate:predicate sortDescriptiors:nil];
    
    if ([objects count]) {
        // update the relationship between the child and the found parent
        if ([parentType isEqualToString:COLLECTION_RECORD_TYPE]) {
            
            Thought *childThought = (Thought *) child;
            Collection *parentCollection = (Collection *) objects[0];
            childThought.parentCollection = parentCollection;
            [parentCollection addThoughtsObject:childThought]; // TODO - lets not unconditionally add the thought. What if it's already there?
            
        } else {
            
            Photo *childPhoto = (Photo *) child;
            Thought *parentThought = (Thought *) objects[0];
            childPhoto.parentThought = parentThought;
            [parentThought addPhotosObject:childPhoto];
            
        }
    }
    
}

#pragma mark - Cloud Kit Fetch

// Convience
+ (void) fetchRecordWithRecordId: (nonnull CKRecordID *) recordId fromDatabase: (CKDatabase *) database withCompletionHandler: (void(^)(CKRecord *record, NSError *error)) block {
    [database fetchRecordWithID:recordId completionHandler:block];
}

// Operation
+ (CKQueryOperation *) operationFetchRecordsOfType: (NSString *) recordType predicate: (NSPredicate *) predicate
                  withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
                withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock {
    // if recordType is not one of the record types saved to CloudKit, return a nil CKQueryOperation
    if  (![Fetcher supportedRecordType:recordType]) {
        return nil;
    }
    
    // a query that will return all objects of type recordType
    CKQuery *queryRecordType = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    
    // fill in the details of the operation to return
    CKQueryOperation *operationFetchRecords = [[CKQueryOperation alloc] initWithQuery:queryRecordType];
    operationFetchRecords.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    operationFetchRecords.recordFetchedBlock = recordFetchedBlock;
    operationFetchRecords.queryCompletionBlock = queryCompletionBlock;
    
    return operationFetchRecords;
}

// Operation made Convinient
+ (void) fetchRecordsFromCloudKitOfType: (nonnull NSString *) recordType predicate: (nonnull NSPredicate *) predicate
                      sortDescriptiors: (NSArray <NSSortDescriptor *> *) sortDescriptors withCompletionBlock: (FacadeBlock)block
{
    // if recordType is not one of the record types saved to CloudKit, return an error
    if  (![Fetcher supportedRecordType:recordType]) {
        NSLog(@"record type does not match Collection, Thought, or Photo");
        // TODO - create custom error
        NSError *error = [NSError errorWithDomain:@"incorrect type" code:0 userInfo:nil];
        block(nil, error);
    }
    
    // a query that will return  objects of type recordType based on a predicate
    CKQuery *queryRecordType = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    
    // set the sort descriptors
    if (!sortDescriptors) {
        NSSortDescriptor *placementSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"placement"
                                                                                ascending:YES];
        queryRecordType.sortDescriptors = [NSArray arrayWithObject:placementSortDescriptor];
    } else {
        queryRecordType.sortDescriptors = sortDescriptors;
    }
    
    // prioritize the operation
    CKQueryOperation *operationFetchRecords = [[CKQueryOperation alloc] initWithQuery:queryRecordType];
    operationFetchRecords.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    
    // a variable to hold the records that will be used in the block
    __block NSMutableArray<CKRecord *> *recordsToReturn;
    
    RecordFetchBlock recordFetchedBlock = ^(CKRecord *record) {
        [recordsToReturn addObject:record];
    };
    
    QueryCompletionBlock queryCompletionBlock = ^(CKQueryCursor * _Nullable cursor, NSError * _Nullable operationError) {
        // if there is a cursor handle the cursor and at the end of the cursor cycle, the block will be handled
        if (cursor) {
            [Fetcher handleQueryWithCursor:cursor recordFetchedBlock:recordFetchedBlock queryCompletionBlock:queryCompletionBlock];
        } else { // if there is NO cursor, handle the block now
            block(recordsToReturn, operationError);
        }
    };
    
    operationFetchRecords.recordFetchedBlock = recordFetchedBlock;
    operationFetchRecords.queryCompletionBlock = queryCompletionBlock;
    
    // add the operation to the database
    CKDatabase *database = [[CKContainer defaultContainer] privateCloudDatabase];
    [database addOperation:operationFetchRecords];
}

// TODO - simulate a cursor
// Cursor
+ (void) handleQueryWithCursor: (nonnull CKQueryCursor *) cursor recordFetchedBlock: (RecordFetchBlock) recordFetchedBlock queryCompletionBlock: (QueryCompletionBlock) queryCompletionBlock {
    
    // start this operation where the last left off
    CKQueryOperation *operationFetchStrandedRecords = [[CKQueryOperation alloc] initWithCursor:cursor];
    
    // set the blocks so that they are the same as the blocks of the original query
    operationFetchStrandedRecords.recordFetchedBlock = recordFetchedBlock;
    operationFetchStrandedRecords.queryCompletionBlock = queryCompletionBlock;
    
    // add the operation to the database
    CKDatabase *database = [[CKContainer defaultContainer] privateCloudDatabase];
    [database addOperation:operationFetchStrandedRecords];
}

#pragma mark - Utilities

+ (BOOL) supportedRecordType: (NSString *) recordType {
    return (([recordType isEqualToString:COLLECTION_RECORD_TYPE]) ||
            ([recordType isEqualToString:THOUGHT_RECORD_TYPE]) ||
            ([recordType isEqualToString:PHOTO_RECORD_TYPE]));
}

@end


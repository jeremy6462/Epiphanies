//
//  Fetcher.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/26/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Fetcher.h"

@implementation Fetcher

#pragma mark - Core Data Fetch

-(nullable NSArray<id<FunObject>> *) fetchRecordsFromCoreDataContext: (nonnull NSManagedObjectContext *) context
                                                                type: (nonnull NSString *) recordType
                                                           predicate: (nonnull NSPredicate *) predicate
                                                    sortDescriptiors: (nullable NSArray <NSSortDescriptor *> *) sortDescriptors
{
    // if recordType is not one of the record types saved to CloudKit, return nil
    if  (![self supportedRecordType:recordType]) {
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

#pragma mark - Cloud Kit Fetch

-(CKQueryOperation *) operationFetchRecordsOfType: (NSString *) recordType predicate: (NSPredicate *) predicate
                  withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
                withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock {
    // if recordType is not one of the record types saved to CloudKit, return a nil CKQueryOperation
    if  (![self supportedRecordType:recordType]) {
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

-(void) fetchRecordsFromCloudKitOfType: (nonnull NSString *) recordType predicate: (nonnull NSPredicate *) predicate
                      sortDescriptiors: (NSArray <NSSortDescriptor *> *) sortDescriptors withCompletionBlock: (FacadeBlock)block
{
    // if recordType is not one of the record types saved to CloudKit, return an error
    if  (![self supportedRecordType:recordType]) {
        NSLog(@"record type does not match Collection, Thought, or Photo");
        NSError *error = [NSError errorWithDomain:@"incorrect type" code:0 userInfo:nil];
        block(nil, error);
    }
    
    // a query that will return all objects of type recordType
    CKQuery *queryRecordType = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    
    // set the sort descriptors
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
            [self handleQueryWithCursor:cursor recordFetchedBlock:recordFetchedBlock queryCompletionBlock:queryCompletionBlock];
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
-(void) handleQueryWithCursor: (nonnull CKQueryCursor *) cursor recordFetchedBlock: (RecordFetchBlock) recordFetchedBlock queryCompletionBlock: (QueryCompletionBlock) queryCompletionBlock {
    
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

-(BOOL) supportedRecordType: (NSString *) recordType {
    return (([recordType isEqualToString:COLLECTION_RECORD_TYPE]) ||
            ([recordType isEqualToString:THOUGHT_RECORD_TYPE]) ||
            ([recordType isEqualToString:PHOTO_RECORD_TYPE]));
}

@end


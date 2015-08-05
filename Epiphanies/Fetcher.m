//
//  Fetcher.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/26/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Fetcher.h"

@implementation Fetcher

#pragma mark - Thoughts within a Collection

-(CKQueryOperation *)fetchAllThoughtsWithParentID:(CKRecordID*) parentID
                            withRecordFetchedBlock:(void (^)(CKRecord *))recordFetchedBlock
                          withQueryCompletionBlock:(void (^)(CKQueryCursor *, NSError *))queryCompletionBlock{
    
    // get a reference to the parent
    CKReference *parent = [[CKReference alloc] initWithRecordID:parentID action:CKReferenceActionNone];
    
    // a predicate that specifies that we want thoughts with this specific parent
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", parent];
    
    // query for all relevant Thoughts
    CKQuery *query = [[CKQuery alloc] initWithRecordType:THOUGHT_RECORD_TYPE predicate:predicate];
    CKQueryOperation *operationToReturn = [[CKQueryOperation alloc] initWithQuery:query];
    
    // set the relevant blocks and quality of service
    operationToReturn.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    operationToReturn.recordFetchedBlock = recordFetchedBlock;
    operationToReturn.queryCompletionBlock = queryCompletionBlock;
    
    return operationToReturn;
}

-(CKQueryOperation *)fetchAllPhotosWithParentID:(CKRecordID*) parentID
                          withRecordFetchedBlock:(void (^)(CKRecord *))recordFetchedBlock
                        withQueryCompletionBlock:(void (^)(CKQueryCursor *, NSError *))queryCompletionBlock{
    
    // get a reference to the parent
    CKReference *parent = [[CKReference alloc] initWithRecordID:parentID action:CKReferenceActionNone];
    
    // a predicate that specifies that we want thoughts with this specific parent
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == %@", parent];
    
    // query for all relevant Thoughts
    CKQuery *query = [[CKQuery alloc] initWithRecordType:PHOTO_RECORD_TYPE predicate:predicate];
    CKQueryOperation *operationToReturn = [[CKQueryOperation alloc] initWithQuery:query];
    
    // set the relevant blocks and quality of service
    operationToReturn.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    operationToReturn.recordFetchedBlock = recordFetchedBlock;
    operationToReturn.queryCompletionBlock = queryCompletionBlock;
    
    return operationToReturn;
}


#pragma mark - All Records of a Given Type

-(CKQueryOperation *)  fetchAllRecordType: (NSString *) recordType
                   withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
                 withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock {
    
    // a predicate that will return all objects
    NSPredicate *allPredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    
    CKQueryOperation *operationToReturn = [self fetchRecordsOfType:recordType predicate:allPredicate
                                            withRecordFetchedBlock:recordFetchedBlock withQueryCompletionBlock:queryCompletionBlock];
    
    return operationToReturn;

}

-(CKQueryOperation *) fetchRecordsOfType: (NSString *) recordType predicate: (NSPredicate *) predicate
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

#pragma mark - Utilities

-(BOOL) supportedRecordType: (NSString *) recordType {
    return (([recordType isEqualToString:COLLECTION_RECORD_TYPE]) ||
            ([recordType isEqualToString:THOUGHT_RECORD_TYPE]) ||
            ([recordType isEqualToString:PHOTO_RECORD_TYPE]));
}

@end

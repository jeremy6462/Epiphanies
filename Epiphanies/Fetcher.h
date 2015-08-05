//
//  Fetcher.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/26/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FundementalObjectHeaders.h"

@interface Fetcher : NSObject

/*!
 @abstract fetches all of the Thought objects that reference a given parentId in CloudKit
 */
-(nullable CKQueryOperation *)fetchAllThoughtsWithParentID:(nonnull CKRecordID*) parentID
                           withRecordFetchedBlock:(void (^)(CKRecord *))recordFetchedBlock
                                  withQueryCompletionBlock:(void (^)(CKQueryCursor* cursor, NSError* error))queryCompletionBlock;

/*!
 @abstract fetches all of the Photo objects that reference a given parentId in CloudKit
 */
-(nullable CKQueryOperation *)fetchAllPhotosWithParentID:(nonnull CKRecordID*) parentID
                                  withRecordFetchedBlock:(void (^)(CKRecord *))recordFetchedBlock
                                withQueryCompletionBlock:(void (^)(CKQueryCursor* cursor, NSError* error))queryCompletionBlock;

/*!
 @discussion calls fetchRecordsOfType: predicate: withRecordFetchedBlock: withQueryCompletionBlock: with a predicate of TRUEPREDICATE
 @return CKQueryOperation that (when executed) will fetch all records of a given type. nil if recordType is not valid (a record type that we save)
 @param recordType is a string that describes the type of record to fetch
 @param recordFetchedBlock "This block will be called once for every record that is returned as a result of the query. The callbacks will happen in the order that the results were sorted in."
 @param queryCompletionBlock "This block is called when the operation completes. The [NSOperation completionBlock] will also be called if both are set."
 */
-(nullable CKQueryOperation *)  fetchAllRecordType: (nonnull NSString *) recordType
                            withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
                          withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock;

/*!
 @return CKQueryOperation that (when executed) will fetch records of a given type based on some predicate. nil if recordType is not valid (a record type that we save)
 @param recordType is a string that describes the type of record to fetch
 @param recordFetchedBlock "This block will be called once for every record that is returned as a result of the query. The callbacks will happen in the order that the results were sorted in."
 @param queryCompletionBlock "This block is called when the operation completes. The [NSOperation completionBlock] will also be called if both are set."
 */
-(nullable CKQueryOperation *) fetchRecordsOfType: (nonnull NSString *) recordType predicate: (nonnull NSPredicate *) predicate
                  withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
                withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock;

@end

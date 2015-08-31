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

// to simplify block syntax
typedef void (^RecordFetchBlock)(CKRecord *record);
typedef void (^QueryCompletionBlock)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError);
typedef void(^FacadeBlock)(NSArray<CKRecord *> *records, NSError *error);

#pragma mark - Core Data

/*!
 @abstract Completes a fetch from the Core Data context or store based on a set of specifications
 @param context The context to execute the fetch in. Nonnull because no fetch could occur without a context
 @param recordType The type of record that should be fetched (ie. Thought, Collection, or Photo). If not one of these three, retuns nil. Nonnull because we must fetch a certain record type
 @param predicate The logical condition that returned records will match. Nonnull because there must be some specification to match records with (even if it is TRUEPREDICATE)
 @param sortDescriptors Objects will be sorted based on the order specified. Nullable because no sort descriptors is requried. If nil, will return in order of placement key
 @return An array of objects fetched from the database. Because we're only storing FundObjects in the database, those should be the only objects returned. If nil, there was an error fetching and this was printed to the console with the prefix "core data fetch error".
 */
-(nullable NSArray<id<FunObject>> *) fetchRecordsFromCoreDataContext: (nonnull NSManagedObjectContext *) context
                                                                type: (nonnull NSString *) recordType
                                                           predicate: (nonnull NSPredicate *) predicate
                                                    sortDescriptiors: (nullable NSArray <NSSortDescriptor *> *) sortDescriptors;

#pragma mark - Cloud Kit

/*!
 @return CKQueryOperation object that can be executed to fetch objects based on a given predicate
 */
-(CKQueryOperation *) operationFetchRecordsOfType: (NSString *) recordType predicate: (NSPredicate *) predicate
                  withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
                withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock;

/*!
 @abstract executes a query to find all records that match a given predicate. Returns those recrods through the block
 @param recordType is a string that describes the type of record to fetch
 @param predicate The predicate the specifies which records to return (if not all records
 @param sortDescriptors The sort descritptors to that describe the sorting of returned records. If nil, sorts on placement
 @param block The completion block that will be executed. Contains the records that were fetched and an error that could have occured during fetching
 */
-(void) fetchRecordsFromCloudKitOfType: (nonnull NSString *) recordType
                             predicate: (nonnull NSPredicate *) predicate
                      sortDescriptiors: (nullable NSArray <NSSortDescriptor *> *) sortDescriptors
                   withCompletionBlock: (nonnull FacadeBlock)block;

/*!
 @abstract Handles the cursors that could return from a large fetch by creating a new operation that will start where the cursor describes (where the previous fetch left off)
 @discussion Pass the recordFetchBlock and queryCompletionBlock that were used in the calling method so that the results can be compiled together
 @param recordFetchedBlock The block called when each record is fetched. Use the same block from the originating call or pool the new records into an array containing the previous records so all records are in the same place
 @param queryCompletionBlock The block called at the end of fetching, if there is an error, or if there is another cursor. If there is a cursor, call this method again with the same completion block so that fetches keep recusively happening until there is no curson returend
 */
-(void) handleQueryWithCursor: (nonnull CKQueryCursor *) cursor recordFetchedBlock: (RecordFetchBlock) recordFetchedBlock queryCompletionBlock: (QueryCompletionBlock) queryCompletionBlock;

@end

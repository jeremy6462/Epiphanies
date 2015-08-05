//
//  Model.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"
#import "CloudAccessors.h"

@interface Model : NSObject

@property (nonnull, nonatomic, strong) CKContainer *container;
@property (nonnull, nonatomic, strong) CKDatabase *database;
@property (nullable, nonatomic, strong) CKRecordZoneID *zoneId;

@property (nonnull, nonatomic, strong) Fetcher *fetcher;
@property (nonnull, nonatomic, strong) Saver *saver;
@property (nonnull, nonatomic, strong) Deleter *deleter;

#pragma mark - Saving

// Althought we save arrays of objects, these arrays could just hold one object

/*!
 @abstract saves an array of Collection objects and no Thought or Photo Children 
 TODO - is there a time when we should save a collection and all of it's Thoughts??
 */
-(void) saveCollectionsToCloudKit: (nonnull NSArray<id<FunObject>> *) collections
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract saves an array of Thought objects and Photo children to CloudKit (used when we move a couple thoughts from one array to another
 */
-(void) saveThoughtsToCloudKit: (nonnull NSArray<id<FunObject>> *) thoughts
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract saves an array of Photo objects to CloudKit
 TODO - will this be used? Is there an analytics package that will track when each method is used?
 */
-(void) savePhotosToCloudKit: (nonnull NSArray<id<FunObject>> *) photos
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract saves an array of objects to CloudKit
 @discussion only saves the objects included in the array, NO CHILDREN
 */
-(void) saveObjectsToCloudKit: (nonnull NSArray<id<FunObject>> *) objects
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract creates a custom zone for this current user
 */
- (void) createZoneAssignZoneID;

#pragma mark - Fetching

/*!
 @abstract loads in all of the current user's collections (fully populated) so the view controller can use updated data
 */
- (void) reloadWithCompletion:(void(^)(NSArray<Collection *> *populatedCollections, NSError *error))block;


// add notification creator for a general object and save

@end

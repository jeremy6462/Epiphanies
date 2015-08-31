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
#import "StringConstants.h"

@interface Model : NSObject

@property (nonnull, nonatomic, strong) NSManagedObjectContext *context;

@property (nonnull, nonatomic, strong) CKContainer *container;
@property (nonnull, nonatomic, strong) CKDatabase *database;
@property (nullable, nonatomic, strong) CKRecordZoneID *zoneId;

@property (nonnull, nonatomic, strong) Fetcher *fetcher;
@property (nonnull, nonatomic, strong) Saver *saver;
@property (nonnull, nonatomic, strong) Deleter *deleter;

#pragma mark - Initializer

// TODO - Singleton didn't work because I was importing the Model inside the model object classes and there was a loop?

/*!
 @abstract returns and instance of the Model class with properties initialized as well
 */
- (nullable instancetype)init;

#pragma mark - Zone Saver

/*!
 @abstract creates a custom zone for this current user and saves subscriptions for all record types (Collection, Thought, Photo)
 */
- (void) createZoneAssignZoneID;

#pragma mark - Entire Record Savers

// Althought we save arrays of objects, these arrays could just hold one object

/*!
 @abstract saves an array of Collection objects and no Thought or Photo Children 
 @discussion also saves the core data context
 TODO - is there a time when we should save a collection and all of it's Thoughts??
 @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
 @param perRecordCompletionBlock a block that will be executed after each record is saved
 @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
 */
-(void) saveCollections: (nonnull NSArray<Collection *> *) collections
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract saves an array of Thought objects and Photo children to CloudKit (used this also when we move a couple thoughts from one collection to another)
 @discussion also saves the core data context
 @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
 @param perRecordCompletionBlock a block that will be executed after each record is saved
 @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
 */
-(void) saveThoughts: (nonnull NSArray<Thought *> *) thoughts
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract saves an array of Photo objects to CloudKit
 TODO - will this be used? Is there an analytics package that will track when each method is used?
 @discussion also saves the core data context
 @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
 @param perRecordCompletionBlock a block that will be executed after each record is saved
 @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
 */
-(void) savePhotos: (nonnull NSArray<Photo *> *) photos
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract saves an array of objects to CloudKit
 @discussion only saves the objects included in the array, NO CHILDREN. Also saves the core data context
 @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
 @param perRecordCompletionBlock a block that will be executed after each record is saved
 @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
 */
-(void) saveObjects: (nonnull NSArray<id<FunObject>> *) objects
   withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
 withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
          withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

#pragma mark - Portion of Record Saver

/*!
 @param object the objects (including recordId) whose to be saved to CloudKit
 @discussion also saves the core data context
 @param dictionaryOfChanges a dictionary with NSString keys of which properties to include in the partial record to save and values that are the new values. To delete a key, use the Remove enum. Only use property strings that detail actual properties the object has (eg. don't use emailURL for a Photo object because Photo's don't have a emailURL property)
 */
-(void) saveObject: (nonnull id<FunObject>) object withChanges:(nonnull NSDictionary *) dictionaryOfChanges
      withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
    withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
             withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

#pragma mark - Order of Record Savers

/*!
 @abstract saves the order of each object to CloudKit by changing each object's _placement value according to their location in the array and saving the new placements to the databse
 @discussion also saves the core data context
 @param objectsOfSameType should be an array of all Collection, Thought, or Photo objects. Do not mix and match object types. All objects should be of the same type. If not, unexpected behavior will occur.
 */
-(void) saveOrderOfObjects: (nonnull NSArray<id<FunObject>> *) objectsOfSameType
withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
       withCompletionBlock: (nullable void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;


#pragma mark - Fetching

/*!
 @abstract loads in all of the current user's collections (fully populated) so the view controller can use updated data
 */
- (void) reloadWithCompletion:(void(^)(NSArray<Collection *> *populatedCollections, NSError *error))block;


/*!
 @abstract - fetches a single record (used when a CKQueryNotification comes in) 
 @param recordFetchedBlock handle the utilization of the record in this block 
 @param queryCompletionBlock handle errors with this block
 TODO - should we have one convience completion handler or the per record completion handler? Populate array and pass back
 */
-(void) fetchRecordWithId: (nonnull CKRecordID *) recordId withRecordType: (nonnull NSString *) type
   withRecordFetchedBlock: (void(^)(CKRecord *record))recordFetchedBlock
 withQueryCompletionBlock: (void(^)(CKQueryCursor * __nullable cursor, NSError * __nullable operationError))queryCompletionBlock;

/*!
 @abstract fetches a record from cloud kit based on the provided recordId and type. Then refreshes the associated model object in core data based on the information provided in the fetched record. If no model object is found, a new model object is created and added to the context, based on the record provided.
 @discussion used in recieving a new notification
 */
-(void) refreshObjectWithRecordId:(nonnull CKRecordID *)recordId;

/*!
 @abstract refreshes the associated model object in core data based on the information provided in the fetched record. If no model object is found, a new model object is created and added to the context, based on the record provided.
 */
-(id<FunObject>) refreshObjectBasedOnRecord: (nonnull CKRecord *) record;

/*!
 @abstract finds the parent for a given child
 @discussion it is the child's responsibility to find the parent and parents will not find their children
 */
-(void) findParentAndUpdateRelationship: (nonnull id<Child>) child parentId: (nonnull CKRecordID *) parentId;

#pragma mark - Deleting

/*!
 @abstract deletes an objcet from CloudKit's database
 @param object the object that will be deleted from cloud kit
 @param block the completion handler that will be run after object deletion
 */
-(void) deleteObjectFromCloudKit: (nonnull id<FunObject>) object completionHandler:(void(^)( NSError * _Nullable error))block;

/*!
 @abstract delete the object from core data
 */
-(void) deleteObjectFromCoreData: (id<FunObject>) object;

/*!
 @abstract deletes an object from core data based on some recordId
 */
-(void) deleteObjectFromCoreDataWithRecordId: (nonnull CKRecordID *) recordId withType: (nonnull NSString *) type;

#pragma mark - Utilities

- (void) clearUserDefautls;

- (void) executeContainerOperation: (nonnull CKOperation *) operation;

@end

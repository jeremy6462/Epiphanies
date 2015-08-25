//
//  Saver.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/2/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"
#import "FundementalObjectHeaders.h"
#import "ForFundamentals.h"

@interface Saver : NSObject

// ATTENTION - Once edits happen to one collection, they will be saved and then more edits can occur. Don't need to flatten Collections and save their thoughts because collection chages happen irrespecitivly of notes

// ATTENTION - On object initialization, the recordId property is built based on the custom zoneId. Because of this, all records should save (upon creation in asRecord) into the correct custom zone for this user

/*!
 @abstract use to save any fun object to CloudKit
 @param arrayOfObjects that only holds Fundamental Objects (have an asRecord method). Each object is converted into a record using it's asRecord method and added to an array of objects that will be saved through the CKOperation
 @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
 @param perRecordCompletionBlock a block that will be executed after each record is saved
 @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
 @return a CKOperation that (when executed - added to a queue) will save an arrayOfObjects to CloudKit
 */
-(nonnull CKModifyRecordsOperation *) saveObjects: (nonnull NSArray<id<FunObject>> *) arrayOfObjects
      withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
    withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
             withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;

/*!
 @abstract use to save only specific changes to a record
 @param object is a Collection, Thought, or Photo
 @param dictionary of changes (NSString (property keys) : NSObject (new values - or Remove enum if you want to remove an old value)
 @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
 @param perRecordCompletionBlock a block that will be executed after each record is saved
 @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
 @return a CKOperation that (when executed - added to a queue) will save object to CloudKit
 */
-(nonnull CKModifyRecordsOperation *) saveObject: (id<FunObject>) object withChanges: (NSDictionary *) dictionaryOfChanges
                      withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
                    withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error))perRecordCompletionBlock
                             withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError))modifyRecordsCompletionBlock;

/*!
 @discussion Thoughts have an array of Photo objects and therefore a a relational-hierarchy. We want to save all Photos related to a Thought and so we flatten each Thought so that each Photo object is represented in the array to save. Input, just Thought objects. Output, those original Thoughts and thier related Photos alongside them
 @param arrayOfThoughts is an array of soley Thought objects with their related photos
 @return an array of objects to save to CloudKit that were originally trapped in the hierarchy of a Thought
 */
-(nonnull NSArray<id<FunObject>> *) flattenThoughtsAndPhotos: (nonnull NSArray<Thought *> *) arrayOfThoughts;

@end






///*!
// @abstract saves the order of an array objects by changing the placement value of each object to match their postion in the array
// @param arrayOfObjects that only holds Fundamental Objects (have an asRecord method). Each object is converted into a record using it's asRecord method and added to an array of objects that will be saved through the CKOperation
// @param perRecordProgressBlock a block that will pass through the current progress of the bulk save operation
// @param perRecordCompletionBlock a block that will be executed after each record is saved
// @param modifyRecordsCompletionBlock a block that will be run after the entire operation is completed
// @return a CKOperation that (when executed - added to a queue) will save an arrayOfObjects to CloudKit
// */
//-(nonnull CKModifyRecordsOperation *)saveOrderOfObjects:(nonnull NSArray<id<FunObject>> *)arrayOfObjects withPerRecordProgressBlock:(nullable void (^)(CKRecord *, double))perRecordProgressBlock withPerRecordCompletionBlock:(nullable void (^)(CKRecord * _Nullable, NSError * _Nullable))perRecordCompletionBlock withCompletionBlock:(nonnull void (^)(NSArray *, NSArray *, NSError *))modifyRecordsCompletionBlock;


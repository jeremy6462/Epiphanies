//
//  Thought.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/27/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Frameworks.h"
#import "ForFundamentals.h"

@class Collection, Photo;

NS_ASSUME_NONNULL_BEGIN

@interface Thought : NSManagedObject <FunObject, Child, Orderable>

// ATTENTION - type as a key is just for records. When asRecord: is called, type will be set for the record and don't worry about keeping it on the in memory model objects

#pragma mark - Initializers

/*!
 NOTE - I replaced the long initializer with a plain old init method and you can set property values manually. This way, we don't need keep updating the intializer every time we want to change a thought
 @abstract Creates a new Thought object through core data (with the context) with generic recordId, objectId, placement
 @discussion parentCollection will still be nil after this method executes. All other properties will have to be initalized by the utilizer of this Thought
 @param context The NSManagedObjectContext to add this Thought object to
 @param collection The parent Collection of this Thought object. Nullable so that parentCollection could be set at a later time
 */
+ (nullable instancetype) newThoughtInManagedObjectContext: (NSManagedObjectContext *) context collection: (nullable Collection *) collection;

/*!
 @abstract creates a new Thought based on a CKRecord
 */
+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record;

/*!
 @abstract Converts a CKRecord into a Thought object (instatiated through core data).
 @discussion Takes the properties in the record and set the associated values in a Thought object instantiated through core data.
 @param context The NSManagedObjectContext to add this Thought object to
 @param record The CKRecord to base this thought object off of
 @param collection The parent Collection of this Thought object. Nullable so that parentCollection could be set at a later time
 */
+ (nullable instancetype) newThoughtInManagedObjectContext: (NSManagedObjectContext *) context basedOnCKRecord: (CKRecord *) record collection: (nullable Collection *) collection;

/*!
 @abstract Creates a Thought object inserted into the context
 */
+ (nullable instancetype) createManagedObject: (nonnull NSManagedObjectContext *) context;

#pragma mark - Record Returners

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created. Make sure that this object has a parentCollection reference first before this method is called
 */
-(nonnull CKRecord *) asRecord;

/*!
 @abstract this method will return a record that represent the sending Collection object, however only contains the attributes for values that have changed
 @param dictionaryOfChanges is a dictionary with keys of property names (macro's found in ForFundamentals.h) that were changed since object creation and values of the change object value. The only keys that are present are those represent properties that are actually saved on the database. PARENT_COLLECTION_KEY should hold a Collection object
 */
-(nonnull CKRecord *) asRecordWithChanges: (nonnull NSDictionary *) dictionaryOfChanges; // TODO - fix generic of dictionary with protocol acceptor

#pragma mark - Update

/*!
 @abstract updates properties based on the properties fetched from CloudKit
 */
-(void) updateBasedOnCKRecord: (nonnull CKRecord *) record;


#pragma mark - Delete Self from Parent

/*!
 @abstract - this method removes this Thought from it's parent's thoughts array
 */
-(void) removeFromParent;


#pragma mark - Utilities 

/*!
 @abstract - moves surrounding impacted thought's placement values accordingly based on the future deletion of the objectToDelete
 */
+ (void) updatePlacementForDeletionOfThought: (Thought *) objectToDelete inThoughts: (NSArray<Thought *>*) thoughts;
@end

NS_ASSUME_NONNULL_END

#import "Thought+CoreDataProperties.h"

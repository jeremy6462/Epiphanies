//
//  Collection.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/27/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Frameworks.h"
#import "ForFundamentals.h"

@class Thought;

NS_ASSUME_NONNULL_BEGIN

@interface Collection : NSManagedObject <FunObject, Orderable>

#pragma mark - Initalizer

/*!
 @abstract Initializes a new Collection with a given name in the given context
 @discussion objectId, recordId, placement, and thoughts will generic values
 @param context The NSManagedObjectContext to insert the new Collection into
 @param name The name of the Collection to be

 */
+ (nullable instancetype) newCollectionInManagedObjectContext:(nonnull NSManagedObjectContext *) context name:(nullable NSString *)name;

+ (nullable instancetype) newCollectionInManagedObjectContext:(NSManagedObjectContext *)context placement: (nonnull NSNumber *) placement;

/*!
 @abstract creates a new Collection in the context
 @discussion this method returns a Collection object according to the CKRecord provided, however because an array of Thought objects is not passed (an one will not come with the record), the thoughts property must be filled after this initialization
 @param context The NSManagedObjectContext to insert the new Collection into
 @param the record to base the collection off of
 */
+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record;

#pragma mark - Record Returner

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created
 */
-(nonnull CKRecord *) asRecord;

/*!
 @abstract this method will return a record that represent the sending Collection object, however only contains the attributes for values that have changed
 @discussion the purpose is to only save (to CloudKit) the objects that have changed since creation
 @param dictionaryOfChanges is a dictionary with keys of property names (macro's found in ForFundamentals.h) that were changed since object creation and values of the change object value. The only keys present are those that would be saved to the database
 */
-(nonnull CKRecord *) asRecordWithChanges: (nonnull NSDictionary *) dictionaryOfChanges; // TODO - fix generic of dictionary with protocol acceptor

#pragma mark - Update

/*!
 @abstract updates properties based on the properties fetched from CloudKit
 */
-(void) updateBasedOnCKRecord: (nonnull CKRecord *) record;

/**
 *  Updates placement of surrounding sibling collections based on the placement value of the collection being deleted
 *
 *  @param objectToDelete Collection being deleted. The placement value of this object determines which objects in collections will be moved in placement
 *  @param collections    the collections list whose placement values may need to be moved
 */
+ (void) updatePlacementForDeletionOfCollection: (Collection *) objectToDelete inCollections: (NSArray<Collection *>*) collections;

#pragma mark - Utilities

/*!
 @return a random name for a new collection
 */
+(nonnull NSString *) randomCollectionName;

@end

NS_ASSUME_NONNULL_END

#import "Collection+CoreDataProperties.h"

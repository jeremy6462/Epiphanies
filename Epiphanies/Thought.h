//
//  Thought.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"
#import "ForFundamentals.h"
#import "Collection.h"
@class Collection;
#import "Photo.h"
@class Photo;

@interface Thought : NSObject <FunObject, Child>

/*Saved on Database*/   @property (nonnull, nonatomic, strong) NSString *objectId;

                        @property (nonnull, nonatomic, strong) CKRecordID *recordId;

/*Saved on Database*/   @property (nonnull, nonatomic, strong) Collection *parentCollection; // save only the parent reference

/*Saved on Database*/   @property (nullable, nonatomic, strong) NSString *text;
/*Saved on Database*/   @property (nullable, nonatomic, strong) CLLocation *location;
                        @property (nullable, nonatomic, strong) NSArray<Photo *> *photos; // photos are saved on their own with a record of this thought

/*Saved on Database*/   @property (nonnull, nonatomic, strong) NSNumber *placement; // used for ordering thoughts based on a user's preference (save as NSNumber)

#pragma mark - Initializers

/*!
 @abstract this method converts a CKRecord into a Thought object
 @discussion parentCollection will still be nil after this method executes
 */
-(nullable instancetype) initWithRecord: (nonnull CKRecord *) record;

/*!
 @abstract this method converts a CKRecord into a Thought object. photos array is not populated 
 */
-(nullable instancetype)initWithRecord: (nonnull CKRecord *) record collection: (nonnull Collection *) collection;

/*!
 @abstract this method creates a new Thought object with the specified information. It will create a recordId for this object
 @param photos is an array of already created Photo objects
 */
-(nullable instancetype) initWithText: (nullable NSString *) text location: (nullable CLLocation *) location photos: (nullable NSArray<Photo *> *) photos collection: (nonnull Collection *) collection placement: (nonnull NSNumber *) placement;

#pragma mark - Record Returners

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created. Make sure that this object has a parentCollection reference first before this method is called
 */
-(nonnull CKRecord *) asRecord;

/*!
 @abstract this method will return a record that represent the sending Collection object, however only contains the attributes for values that have changed
 @param dictionaryOfChanges is a dictionary with keys of property names (macro's found in ForFundamentals.h) that were changed since object creation and values of the change object value. The only keys that are present are those represent properties that are actually saved on the database. PARENT_COLLECTION_KEY should hold a Collection object, TEXT_KEY should hold @"" if deleting the text
 TODO - how to handle deleting location
 */
-(nonnull CKRecord *) asRecordWithChanges: (nonnull NSDictionary *) dictionaryOfChanges; // TODO - fix generic of dictionary with protocol acceptor

#pragma mark - Delete Self from Parent

/*!
 @abstract - this method removes this Thought from it's parent's thoughts array
 */
-(void) removeFromParent;

@end

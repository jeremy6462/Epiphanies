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

@interface Thought : NSObject <FunObject, Child, Orderable>

// ATTENTION - type as a key is just for records. When asRecord: is called, type will be set for the record and don't worry about keeping it on the in memory model objects

/*Saved on Database*/   @property (nonnull, nonatomic, strong) NSString *objectId;

                        @property (nonnull, nonatomic, strong) CKRecordID *recordId;

/*Saved on Database*/   @property (nonnull, nonatomic, strong) Collection *parentCollection; // save only the parent reference

/*Saved on Database*/   @property (nullable, nonatomic, strong) NSString *text;
/*Saved on Database*/   @property (nullable, nonatomic, strong) CLLocation *location;
                        @property (nullable, nonatomic, strong) NSArray<Photo *> *photos; // photos are saved on their own with a record of this thought

/*Saved on Database*/   @property (nullable, nonatomic, strong) NSString *extraText; // allows for extra description text to be set. Should be in smaller print than headline text and should only appear as an option in text != nil

                        // keep track of which URLs are used
/*Saved on Database*/   @property (nullable, nonatomic, strong) NSString *webURL;
/*Saved on Database*/   @property (nullable, nonatomic, strong) NSString *telURL;
/*Saved on Database*/   @property (nullable, nonatomic, strong) NSString *emailURL;

/*Saved on Database*/   @property (nullable, nonatomic, strong) NSArray<NSString *> *tags;

/*Saved on Database*/   @property (nonnull, nonatomic, strong) NSNumber *placement; // used for ordering thoughts based on a user's preference (save as NSNumber)

                        @property (nonnull, nonatomic, strong) NSDate *creationDate; // it is interesting to understand when this idea was created not nesc. when it was modified - this can be aquired from a record and shouldn't change TODO add to the initializers and asRecords

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
 NOTE - I replaced the long initializer with a plain old init method and you can set property values manually. This way, we don't need keep updating the intializer every time we want to change a thought
 @abstract Creates a new Thought object with generic recordId, objectId, placement, and photos array
 @discussion parentCollection will still be nil after this method executes
 */
-(nullable instancetype) init;

#pragma mark - Record Returners

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created. Make sure that this object has a parentCollection reference first before this method is called
 */
-(nonnull CKRecord *) asRecord;

/*!
 @abstract this method will return a record that represent the sending Collection object, however only contains the attributes for values that have changed
 @param dictionaryOfChanges is a dictionary with keys of property names (macro's found in ForFundamentals.h) that were changed since object creation and values of the change object value. The only keys that are present are those represent properties that are actually saved on the database. PARENT_COLLECTION_KEY should hold a Collection object
 TODO - investigate Key-Value property usage for objects. We could just loop through the dictionaryOfChanges and set a record's key value equal to the value behind self's same key
 */
-(nonnull CKRecord *) asRecordWithChanges: (nonnull NSDictionary *) dictionaryOfChanges; // TODO - fix generic of dictionary with protocol acceptor

#pragma mark - Delete Self from Parent

/*!
 @abstract - this method removes this Thought from it's parent's thoughts array
 */
-(void) removeFromParent;

@end

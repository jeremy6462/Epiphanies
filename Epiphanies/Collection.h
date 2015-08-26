//
//  Collection.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Frameworks.h"
#import "ForFundamentals.h"
#import "Thought.h"
@class Thought;

@interface Collection : NSManagedObject <FunObject, Orderable>

/*Saved on Database*/   @property (nonnull, nonatomic, retain) NSString *objectId;

                        @property (nonnull, nonatomic, retain) CKRecordID *recordId; // keep this reference in order to know which record to delete

/*Saved on Database*/   @property (nonnull, nonatomic, retain) NSString *name;
                        @property (nullable, nonatomic, retain) NSArray<Thought *> *thoughts;
/*Saved on Database*/   @property (nullable, nonatomic, retain) NSNumber *placement; // the placement of this Collection within the user's list of collections

/*!
 @abstract initializes a new Collection with a given Name
 @discussion objectId, recordId, placement, and thoughts will generic values
 */
-(nullable instancetype) initWithName: (nonnull NSString *) name;
/*!
 @discussion this method returns a Collection object according to the CKRecord provided, however because an array of Thought objects is not passed (an one will not come with the record), the thoughts property must be filled after this initialization
 */
-(nullable instancetype) initWithRecord: (nonnull CKRecord *) record;

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

/*!
 @return a random name for a new collection
 */
+(nonnull NSString *) randomCollectionName;

@end

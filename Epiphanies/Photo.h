//
//  Photo.h
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

@interface Photo : NSManagedObject <FunObject, Child, Orderable>

#pragma mark - Initalizers

/*!
 @abstract Creates a new Photo object that is inserted into the managed object context
 @discussion A factory method that wraps object initialization in order for core data to do it's thing. Once core data returns our object, we can set its properties based on the parameters
 @param context The NSManagedObjectContext to insert the object into. Is nonnull because there must be a context to insert this object into
 @param image The UIImage that this photo object represents. Is nonnull because there is no reason for a Photo object without an image
 @param thought The parent Thought object of this Photo that holds this photo. If nil, parentThought will be nil
 @return A populated Photo object that is not based on previously created data (new)
 */
+ (nullable instancetype) newPhotoInManagedObjectContext: (nonnull NSManagedObjectContext *) context image: (nonnull UIImage *) image parentThought: (nullable Thought *) thought;

/*!
 @abstract Creates a new Photo based off a CKRecord object
 */
+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record;

/*!
 @abstract Creates a new Photo object that is inserted into the managed object context
 @discussion A factory method that wraps object initialization in order for core data to do it's thing. Once core data returns our object, we can set its properties based on the parameters
 @param context The NSManagedObjectContext to insert the object into. Is nonnull because there must be a context to insert this object into
 @param record The CKRecord that was fetched that contains the data to back this photo
 @param thought The parent Thought object of this Photo that holds this photo. If nil, parentThought will be nil
 @return A populated photo object that is based off of a fetched CKRecord (existing)
 */
+ (nullable instancetype) newPhotoInManagedObjectContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record parentThought: (nullable Thought *) thought;

#pragma mark - Record Returners

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created
 */
-(nonnull CKRecord *) asRecord;

/*!
 @abstract this method will return a record that represent the sending Collection object, however only contains the attributes for values that have changed. ATTENTION - use this method for handling placement changes
 @param dictionaryOfChanges is a dictionary with keys of property names (macro's found in ForFundamentals.h) that were changed since object creation and values of the change object value. The only keys that are present are those represent properties that are actually saved on the database.
 */
-(nonnull CKRecord *) asRecordWithChanges: (nonnull NSDictionary *) dictionaryOfChanges; // TODO - fix generic of dictionary with protocol acceptor

#pragma mark - Update

/*!
 @abstract updates properties based on the properties fetched from CloudKit
 */

-(void) updateBasedOnCKRecord: (nonnull CKRecord *) record;

#pragma mark - Delete Self from Parent

/*!
 @abstract - Removes this Photo from it's parent's photos array
 */
-(void) removeFromParent;

#pragma mark - On Device Image Accessors

/*!
 @abstract saves the image to the temp directory
 @return the URL in the temp directory of the image saved. If the image could not be saved, returns nil
 */
-(nullable NSURL *) saveToTemp;

/*!
 @abstract attempts to find an image stored at a URL
 @return image that was found from the URL. If no image could be found, returns nil
 */
+ (nullable UIImage *) imageFromURL: (nonnull NSString *) filePath;


@end

NS_ASSUME_NONNULL_END

#import "Photo+CoreDataProperties.h"

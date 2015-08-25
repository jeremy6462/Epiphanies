//
//  Photo.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/19/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

@import CloudKit;

#import <Foundation/Foundation.h>
#import "ForFundamentals.h"
#import "Thought.h"
@class Thought;


@interface Photo : NSObject <FunObject, Child, Orderable> // could do this in a category, but making my own app is enough to take on, lets cut ourseleves some slack here

/*Saved on Database*/   @property (nonnull, nonatomic, strong) NSString *objectId;

                        @property (nonnull, nonatomic, strong) CKRecordID *recordId; // keep this reference in order to know which record to delete

/*Saved on Database*/   @property (nullable, nonatomic, strong) Thought *parentThought; // the thought model object that created this image (save as CKReference to parentThought's recordID property

/*Save on Database*/    @property (nonnull, nonatomic, strong) UIImage *image; // save as CKAsset

/*Save on Database*/    @property (nonnull, nonatomic, strong) NSNumber *placement;

#pragma mark - Initalizers

/*!
 @abstract initializes a Photo object based on a record
 @discussion parentThought will still be nil
 */
-(nullable instancetype) initWithRecord: (nonnull CKRecord *) record;
-(nullable instancetype) initWithRecord: (nonnull CKRecord *) record parent: (nonnull Thought *) thought;
/*!
 @abstract intializes a Photo object with generic placement, objectId, and recordId and an image asset
 */
-(nullable instancetype) initWithImage: (nonnull UIImage *) image;

#pragma mark - Record Returners

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created
 */
-(nonnull CKRecord *) asRecord;

/*!
 @abstract this method will return a record that represent the sending Collection object, however only contains the attributes for values that have changed. ATTENTION - use this method for handling placement changes
 @param dictionaryOfChanges is a dictionary with keys of property names (macro's found in ForFundamentals.h) that were changed since object creation and values of the change object value. The only keys that are present are those represent properties that are actually saved on the database.
 TODO - how to handle deleting location
 */
-(nonnull CKRecord *) asRecordWithChanges: (nonnull NSDictionary *) dictionaryOfChanges; // TODO - fix generic of dictionary with protocol acceptor

#pragma mark - Delete Self from Parent

/*!
 @abstract - this method removes this photo from it's parent's photos array
 */
-(void) removeFromParent;

#pragma mark - On Device Image Accessors

/*!
 @abstract saves the image to the temp directory
 @return the URL in the temp directory of the image saved. If the image could not be saved, returns nil
 */
-(nullable NSURL *) saveToTemp;

/*!
 @abstract attemps to find an image stored at a URL
 @return image that was found from the URL. If no image could be found, returns nil;
 */
-(nullable UIImage *) imageFromURL: (nonnull NSString *) filePath;

@end

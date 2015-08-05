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

@interface Photo : NSObject <FunObject> // could do this in a category, but making my own app is enough to take on, lets cut ourseleves some slack here

                        @property (nullable, nonatomic, strong) CKRecordID *recordId; // keep this reference in order to know which record to delete

/*Saved on Database*/   @property (nonnull, nonatomic, strong) NSString *objectId;

/*Saved on Database*/   @property (nullable, nonatomic, strong) Thought *parentThought; // the thought model object that created this image (save as CKReference to parentThought's recordID property

/*Save on Database*/    @property (nonnull, nonatomic, strong) UIImage *image; // save as CKAsset

/*Save on Database*/    @property (nonnull, nonatomic, strong) NSNumber *placement;

/*!
 @abstract initializes a Photo object based on a record
 @discussion parentThought will still be nil
 */
-(nullable instancetype) initWithRecord: (nonnull CKRecord *) record;
-(nullable instancetype) initWithRecord: (nonnull CKRecord *) record parent: (nonnull Thought *) thought;
-(nullable instancetype) initWithImage: (nonnull UIImage *) image parent: (nonnull Thought *) thought placement: (nonnull NSNumber *) placement;

/*!
 @abstract takes all property values that will be saved to the database and adds them as attributes to a record for this object
 @discussion if property _recordId is nil, then a new CKRecord will be created
 */
-(nonnull CKRecord *) asRecord;

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

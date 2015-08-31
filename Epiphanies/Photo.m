//
//  Photo.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/27/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Photo.h"
#import "Thought.h"

@implementation Photo

#pragma mark - Initializers

// ATTENTION - don't worry about the warning for implementing the custom setters and getters. Core data will implement these methods for us which is why the properties are dynamic. If need be, use self.property to access and set these properties

// initalize new Photo
+ (nullable instancetype) newPhotoInManagedObjectContext: (nonnull NSManagedObjectContext *) context image: (nonnull UIImage *) image parentThought: (nullable Thought *) thought {
    
    // a managed object Photo that will be tracked by core data
    Photo *photoToReturn = [Photo createManagedObject: context];
    if (photoToReturn) {
        
        // objectId
        photoToReturn.objectId = [IdentifierCreator createId];
        
        // recordId
        // fabricate the record zone for it's id (it will match the record zone already created TODO - maybe we should just refact the record zone creator to call some method that will make the record zone if it hasn't already been made and return the id
        CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:ZONE_NAME];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE zoneID:zone.zoneID];
        photoToReturn.recordId = record.recordID;
        // TODO - set up transient property to set for recordId for type safety?
        
        // parentThought
        photoToReturn.parentThought = thought;
        [thought addPhotosObject:photoToReturn]; // TODO - make sure this doens't duplicate the photo. It would be nice if we could just make sure to add the photo here and wouldn't need to do it later
        
        // image
        NSData *data = UIImagePNGRepresentation(image);
        photoToReturn.image = data;
        
        // placement
        photoToReturn.placement = [NSNumber numberWithInt:0];
        
    }
    return photoToReturn;
}

+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record {
    
    // a managed object Photo that will be tracked by core data
    Photo *photoToReturn = [Photo createManagedObject: context];
    if (photoToReturn) {
        
        // objectId
        photoToReturn.objectId = [record objectForKey:OBJECT_ID_KEY];
        
        // recordId
        photoToReturn.recordId = record.recordID;
        
        // parentThought
        // image
        CKAsset *asset = [record objectForKey:IMAGE_KEY];
        NSData *data = [[NSData alloc] initWithContentsOfURL:asset.fileURL];
        [photoToReturn setImage:data];
        
        // placement
        photoToReturn.placement = [record objectForKey:PLACEMENT_KEY];
    }
    return photoToReturn;
}

// initalize existing Photo
+ (nullable instancetype) newPhotoInManagedObjectContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record parentThought: (nullable Thought *) thought {
    
    Photo *photoToReturn = [Photo newManagedObjectInContext:context basedOnCKRecord:record];
    
    photoToReturn.parentThought = thought;
    
    return photoToReturn;
}

+ (nullable instancetype) createManagedObject: (nonnull NSManagedObjectContext *) context {
    Photo *photo = (Photo *) [NSEntityDescription insertNewObjectForEntityForName:PHOTO_RECORD_TYPE inManagedObjectContext:context];
    return photo;
}

#pragma mark - Record Returns

-(CKRecord *) asRecord {
    CKRecord *recordToReturn;
    
    // if there is a record id (ie. there is already a record of this object)
    if (self.recordId) {
        recordToReturn = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE recordID:self.recordId];
    } else {
        recordToReturn = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE];
        self.recordId = recordToReturn.recordID;
    }
    
    // objectId
    [recordToReturn setObject:[self objectId] forKey:OBJECT_ID_KEY];
    
    // image
    CKAsset *asset = [[CKAsset alloc] initWithFileURL:[self saveToTemp]];
    [recordToReturn setObject:asset forKey:IMAGE_KEY];
    
    // parentThought
    CKReference *reference = [[CKReference alloc] initWithRecordID:[[self parentThought] recordId] action:CKReferenceActionDeleteSelf];
    [recordToReturn setObject:reference forKey:PARENT_THOUGHT_KEY];
    
    // placement
    [recordToReturn setObject:[self placement] forKey:PLACEMENT_KEY];
    
    // type
    [recordToReturn setObject:PHOTO_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    return recordToReturn;
}

-(CKRecord *) asRecordWithChanges:(NSDictionary *)dictionaryOfChanges {
    CKRecord *record;
    
    // if there is a record id (ie. there is already a record of this object
    if (self.recordId) {
        record = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE recordID:self.recordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE];
        self.recordId = record.recordID;
    }
    
    // loop through the keys in dictionaryOfChanges and build the record accordingly depending on the values stored behind those keys
    for (NSString *key in dictionaryOfChanges) {
        if (dictionaryOfChanges[key] != [NSNull null]) {
            record[key] = dictionaryOfChanges[key];
        } else {
            record[key] = nil;
        }
//        [self setValue:record[key] forKey:key]; // TODO - we could require these be set before hand on the in-memory object or we could force some sort of key check against properties to make sure incorrect keys aren't sent. Problem was a crash due to an incorrect key sent through the dictionary. This is bad because the CKRecord has an incorrect key and because the Photo object won't have the property and the app will crash
    }
    
    [record setObject:PHOTO_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    return record;
}

#pragma mark - Update

-(void) updateBasedOnCKRecord:(CKRecord *)record {
    
    // objectId
    self.objectId = [record objectForKey:OBJECT_ID_KEY];
    
    // recordId
    self.recordId = record.recordID;
    
    // parentThought
    // image
    CKAsset *asset = [record objectForKey:IMAGE_KEY];
    NSData *data = [[NSData alloc] initWithContentsOfURL:asset.fileURL];
    [self setImage:data];
    
    // placement
    self.placement = [record objectForKey:PLACEMENT_KEY];
}

#pragma mark - Delete Self from Parent

-(void) removeFromParent {
    if ([self parentThought]) {
        NSSet<Photo *> *brothers = self.parentThought.photos;
        for (Photo *peer in brothers) {
            if ([[peer objectId] isEqualToString: [self objectId]]) {
                [self.parentThought removePhotosObject:peer];
            }
        }
    }
}

#pragma mark - On Device Image Accessors

-(NSURL *) saveToTemp {
    
    // old filename - extra uniqueness
//    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@", _parentThought.parentCollection.objectId, _parentThought.objectId, _objectId];

    // file url in the temp directory
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *urlOfImage = [[tmpDirURL URLByAppendingPathComponent:[self objectId]] URLByAppendingPathExtension:@"jpg"];
    
    // save image to file url in temp directory
    if (![[self image] writeToURL:urlOfImage atomically:YES]) { // if writing is not a success
        NSLog(@"Failed to save image to temp folder");
        return nil;
    }
    
    return urlOfImage;
}

+ (UIImage *) imageFromURL: (NSString *) filePath {
    UIImage *imageToReturn = [UIImage imageWithContentsOfFile:filePath];
    if (imageToReturn == nil) {
       NSLog(@"Nothing was found at path: %@", filePath);
    }
    return imageToReturn;
}


@end

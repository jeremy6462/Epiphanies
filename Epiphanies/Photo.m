//
//  Photo.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/19/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Photo.h"

@implementation Photo : NSObject

#pragma mark - Initializers

-(instancetype) initWithImage:(nonnull UIImage *)image parent:(nonnull Thought *)thought placement:(nonnull NSNumber *)placement {
    self = [super init];
    if (self) {
        _objectId = [IdentifierCreator createId];
        
        _recordId = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE].recordID;
        
        _image = image;
        _parentThought = thought;
        _placement = placement;
    }
    return self;
}

-(instancetype) initWithRecord:(nonnull CKRecord *)record parent:(nonnull Thought *)thought {
    self = [super init];
    if (self) {
        _objectId = [record objectForKey:OBJECT_ID_KEY];
        
        _recordId = record.recordID;
        
        CKAsset *asset = [record objectForKey:IMAGE_KEY];
        UIImage *image = [UIImage imageWithContentsOfFile:asset.fileURL.path]; // TODO - is the URL here the URL in the temp folder where I saved the image or is it (hopefully) where the fetch downloaded the image to (newly saved from CloudKit - allowing for multiple device photo sync)
        _image = image;
        
        _parentThought = thought;
        
        _placement = [record objectForKey:PLACEMENT_KEY];
    }
    return self;
}

#pragma mark - Record Returns

-(CKRecord *) asRecord {
    CKRecord *recordToReturn;
    
    // if there is a record id (ie. there is already a record of this object
    if (_recordId) {
        recordToReturn = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE recordID:_recordId];
    } else {
        recordToReturn = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE];
        _recordId = recordToReturn.recordID;
    }
    
    [recordToReturn setObject:_objectId forKey:OBJECT_ID_KEY];
    
    // convert and save the properties of this Photo to CKRecordValues
    CKAsset *asset = [[CKAsset alloc] initWithFileURL:[self saveToTemp]];
    [recordToReturn setObject:asset forKey:IMAGE_KEY];
    
    // add a reference to the parent thought
    if (_parentThought.recordId == nil) {
        [_parentThought asRecord]; // this method will make sure that the Thought has a recordId
    }
    CKReference *reference = [[CKReference alloc] initWithRecordID:_parentThought.recordId action:CKReferenceActionDeleteSelf];
    [recordToReturn setObject:reference forKey:PARENT_THOUGHT_KEY];
    
    return recordToReturn;
}

-(CKRecord *) asRecordWithPlacement: (NSNumber *) placement {
    CKRecord *recordToReturn;
    
    // if there is a record id (ie. there is already a record of this object
    if (_recordId) {
        recordToReturn = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE recordID:_recordId];
    } else {
        recordToReturn = [[CKRecord alloc] initWithRecordType:PHOTO_RECORD_TYPE];
        _recordId = recordToReturn.recordID;
    }
    
    [recordToReturn setObject:placement forKey:PLACEMENT_KEY];
    
    return recordToReturn;
}

#pragma mark - Utilities

-(NSURL *) saveToTemp {
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
//    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@", _parentThought.parentCollection.objectId, _parentThought.objectId, _objectId];
    NSURL *urlOfImage = [[tmpDirURL URLByAppendingPathComponent:/*fileName*/_objectId] URLByAppendingPathExtension:@"jpg"];
    
    // save image to temp directory
    NSData *imageData = UIImagePNGRepresentation(_image);
    if (![imageData writeToURL:urlOfImage atomically:YES]) { // if writing is not a success
        NSLog(@"Failed to save image to temp folder");
        return nil;
    }
    
    return urlOfImage;
}

-(UIImage *) imageFromURL: (NSString *) filePath {
    UIImage *imageToReturn = [UIImage imageWithContentsOfFile:filePath];
    if (imageToReturn == nil) NSLog(@"Nothing was found at path: %@", filePath);
    return imageToReturn;
}

@end

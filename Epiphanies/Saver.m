 //
//  Saver.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/2/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Saver.h"

@implementation Saver

#pragma mark - Core Data

+ (nullable NSError *) saveContext: (nonnull NSManagedObjectContext *) context {
        __block NSError *error = nil;
        if ([context hasChanges]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [context save:&error];
            });
        }
        return error;
    
}

#pragma mark - Cloud Kit

// Save complete objects

+ (nonnull CKModifyRecordsOperation *) saveObjects: (nonnull NSArray<id<FunObject>> *) arrayOfObjects
                       withPerRecordProgressBlock: (nullable PerRecordProgressBlock) perRecordProgressBlock
                     withPerRecordCompletionBlock: (nullable PerRecordCompletionBlock) perRecordCompletionBlock
                              withCompletionBlock: (nonnull ModifyRecordsCompletionBlock) modifyRecordsCompletionBlock {
    
    // an array to hold all of the records to save
    NSMutableArray<CKRecord *> *arrayOfRecords = [[NSMutableArray alloc] init];
    
    // go through all of the collections and turn them into records to save
    for (id<FunObject> objectToSave in arrayOfObjects) {
        CKRecord *recordToSave = [objectToSave asRecord];
        [arrayOfRecords addObject:recordToSave];
    }
    
    CKModifyRecordsOperation *operationSaveObjects = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:arrayOfRecords recordIDsToDelete:nil];
    
    // set the qualityOfService (priority of this operation)
    operationSaveObjects.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    
    // handle the user's blocks
    operationSaveObjects.perRecordProgressBlock = perRecordProgressBlock;
    operationSaveObjects.perRecordCompletionBlock = perRecordCompletionBlock;
    operationSaveObjects.modifyRecordsCompletionBlock = modifyRecordsCompletionBlock;
    
    return operationSaveObjects;
}

// Save partial objects

+ (nonnull CKModifyRecordsOperation *) saveObject: (id<FunObject>) object withChanges: (NSDictionary *) dictionaryOfChanges
                      withPerRecordProgressBlock: (nullable PerRecordProgressBlock) perRecordProgressBlock
                    withPerRecordCompletionBlock: (nullable PerRecordCompletionBlock) perRecordCompletionBlock
                             withCompletionBlock: (nonnull ModifyRecordsCompletionBlock) modifyRecordsCompletionBlock {
    
    // create a record that only contains the values that were changed (as detailed in dictionaryOfChanges)
    CKRecord *recordToSave = [object asRecordWithChanges:dictionaryOfChanges];
    
    CKModifyRecordsOperation *operationSaveObject = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[recordToSave] recordIDsToDelete:nil];
    
    // set the qualityOfService (priority of this operation)
    operationSaveObject.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    
    // handle the user's blocks
    operationSaveObject.perRecordProgressBlock = perRecordProgressBlock;
    operationSaveObject.perRecordCompletionBlock = perRecordCompletionBlock;
    operationSaveObject.modifyRecordsCompletionBlock = modifyRecordsCompletionBlock;
    
    return operationSaveObject;
    
}

#pragma mark - Utilities

+ (NSArray<id<FunObject>> *) flattenThoughtsAndPhotos: (NSArray<Thought *> *) arrayOfThoughts {
    
    // an array to hold the original thoughts and photos seperated
    NSMutableArray<id<FunObject>> *objectsToReturn = [[NSMutableArray alloc] init];
    
    // loop through all thoughts in arrayOfThoughts and add them and their photos to objectsToReturn
    for (Thought *thought in arrayOfThoughts) {
        
        // add the Thought to objectsToReturn
        [objectsToReturn addObject:thought];
        
        // loop through all of this thought's photos and add them to the objectsToReturn
        for (Photo *photo in thought.photos) {
            [objectsToReturn addObject:photo];
        }
    }
    
    return objectsToReturn;
}

@end

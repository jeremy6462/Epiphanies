//
//  Saver.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/2/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Saver.h"

@implementation Saver

-(CKModifyRecordsOperation *) saveObjects: (NSArray<id<FunObject>> *) arrayOfObjects
      withPerRecordProgressBlock: (void(^)(CKRecord *record, double progress)) perRecordProgressBlock
    withPerRecordCompletionBlock: (void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
             withCompletionBlock: (void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock {
    
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

-(NSArray<id<FunObject>> *) flattenThoughtsAndPhotos: (NSArray<Thought *> *) arrayOfThoughts {
    
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

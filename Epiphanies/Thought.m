//
//  Thought.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/27/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Thought.h"
#import "Collection.h"
#import "Photo.h"

@implementation Thought

#pragma mark - Initializers

+ (nullable instancetype) newThoughtInManagedObjectContext: (NSManagedObjectContext *) context collection: (nullable Collection *) collection {

    // create a Thought object in the managed object context
    Thought *thoughtToReturn = [Thought createManagedObject:context];
    if (thoughtToReturn) {
        
        // objectId
        thoughtToReturn.objectId = [IdentifierCreator createId];
        
        // placement
        thoughtToReturn.placement = [NSNumber numberWithInt:0];
        
        // recordId
        // fabricate the record zone for it's id (it will match the record zone already created TODO - maybe we should just refact the record zone creator to call some method that will make the record zone if it hasn't already been made and return the id
        CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:ZONE_NAME];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE zoneID:zone.zoneID];
        thoughtToReturn.recordId = record.recordID;
        
        // parentCollection
        thoughtToReturn.parentCollection = collection;
        
        // creation date
        thoughtToReturn.creationDate = [NSDate date];
        
        // photos set should be handled by core data
        
        // rest of the properties are initalized by the utilizer of this Thought
    }
    return thoughtToReturn;
}

+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record {
    // create a Thought object in the managed object context
    Thought *thoughtToReturn = [Thought createManagedObject:context];
    if (thoughtToReturn) {
        
        // objectId
        thoughtToReturn.objectId = [record objectForKey:OBJECT_ID_KEY];
        
        // placement
        thoughtToReturn.placement = [record objectForKey:PLACEMENT_KEY];
        
        // recordId
        thoughtToReturn.recordId = [record recordID];
        
        // extra aspects of a Thought
        thoughtToReturn.text = [record objectForKey:TEXT_KEY];
        thoughtToReturn.location = [record objectForKey:LOCATION_KEY];
        thoughtToReturn.extraText = [record objectForKey:EXTRA_TEXT_KEY];
        thoughtToReturn.tags = [record objectForKey:TAGS_KEY];
        
        // relevant dates
        thoughtToReturn.reminderDate = [record objectForKey:REMINDER_DATE_KEY];
        thoughtToReturn.creationDate = record.creationDate;
    }
    return thoughtToReturn;

}

+ (nullable instancetype) newThoughtInManagedObjectContext: (NSManagedObjectContext *) context basedOnCKRecord: (CKRecord *) record collection: (nullable Collection *) collection {
    
    Thought *thoughtToReturn = [Thought newManagedObjectInContext:context basedOnCKRecord:record];
    
    // parentCollection
    thoughtToReturn.parentCollection = collection;
    
    return thoughtToReturn;
}

+ (nullable instancetype) createManagedObject: (nonnull NSManagedObjectContext *) context {
    Thought *thought = (Thought *) [NSEntityDescription insertNewObjectForEntityForName:THOUGHT_RECORD_TYPE inManagedObjectContext:context];
    return thought;
}

#pragma mark - Record Returns

- (CKRecord *) asRecord {
    
    // get a reference to self's record object. if there is none, create one
    CKRecord *record;
    if (self.recordId) {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE recordID:self.recordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE];
        self.recordId = record.recordID;
    }
    
    // set all of the fields of the record = to the the current fields of self
    record[OBJECT_ID_KEY] = self.objectId;
    
    record[PLACEMENT_KEY] = self.placement;
    
    record[PARENT_COLLECTION_KEY] = [[CKReference alloc] initWithRecordID:self.parentCollection.recordId action:CKReferenceActionDeleteSelf];
    
    record[TEXT_KEY] = self.text;
    record[LOCATION_KEY] = self.location;
    record[EXTRA_TEXT_KEY] = self.extraText;
    record[TAGS_KEY] = self.tags;
    
    record[REMINDER_DATE_KEY] = self.reminderDate;
    
    [record setObject:THOUGHT_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    return record;
    
}

-(CKRecord *) asRecordWithChanges:(NSDictionary *)dictionaryOfChanges {
    
    // get a reference to self's record object. if there is none, create one
    CKRecord *record;
    if (self.recordId) {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE recordID:self.recordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE];
        self.recordId = record.recordID;
    }
    
    /*
     TODO
     Summary - Can we confine the keys that can be placed in dictionaryOfChanges to a specific set of strings?
     Questions - how to handle keys that are not properties? How to handle not putting keys that shouldn't be there (children shouldn't be added to the record).
     Should this be an array and we should forget about the changes?
     */
    // loop through the keys in dictionaryOfChanges and build the record accordingly depending on the values stored behind those keys
    for (NSString *key in dictionaryOfChanges) {
        if (dictionaryOfChanges[key] != [NSNull null]) {
            record[key] = dictionaryOfChanges[key];
        } else {
            record[key] = nil;
        }
        [self setValue:record[key] forKey:key];
    }
    
    
    [record setObject:THOUGHT_RECORD_TYPE forKey:TYPE_KEY]; // used in order to get the type of this record back when a change occurs and a push notification is sent
    
    return record;
}

#pragma mark - Update

-(void) updateBasedOnCKRecord:(CKRecord *)record {
    
    // objectId
    self.objectId = [record objectForKey:OBJECT_ID_KEY];
    
    // placement
    self.placement = [record objectForKey:PLACEMENT_KEY];
    
    // recordId
    self.recordId = [record recordID];
    
    // extra aspects of a Thought
    self.text = [record objectForKey:TEXT_KEY];
    self.location = [record objectForKey:LOCATION_KEY];
    self.extraText = [record objectForKey:EXTRA_TEXT_KEY];
    self.tags = [record objectForKey:TAGS_KEY];
    
    // relevant dates
    self.reminderDate = [record objectForKey:REMINDER_DATE_KEY];
    self.creationDate = record.creationDate;
    
}

#pragma mark - Delete Self from Parent

-(void) removeFromParent {
    for (Thought *thought in self.parentCollection.thoughts) {
        if ([thought.objectId isEqualToString:self.objectId]) {
            [self.parentCollection removeThoughtsObject:thought];
        }
    }
}

#pragma mark - Utilities

-(void) setRecordId:(id)recordId {
    
    [self setPrimitiveValue:recordId forKey:RECORD_ID_KEY];
    
    // set the recordName accordingly
    CKRecordID *castedRecord = (CKRecordID *) recordId;
    [self setRecordName:castedRecord.recordName];
    
}

@end

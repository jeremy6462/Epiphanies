//
//  Collection.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/27/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Collection.h"
#import "Thought.h"

@implementation Collection

#pragma mark - Initializers

+ (nullable instancetype) newCollectionInManagedObjectContext:(nonnull NSManagedObjectContext *) context name:(nullable NSString *)name {
    
    // create a Collection object in the context
    Collection *collectionToReturn = [Collection createManagedObject:context];
    if (collectionToReturn) {
        
        // objectId
        collectionToReturn.objectId = [IdentifierCreator createId];
        
        // placement
        collectionToReturn.placement = [NSNumber numberWithInt:0];
        
        // recordId
        // fabricate the record zone for it's id (it will match the record zone already created TODO - maybe we should just refact the record zone creator to call some method that will make the record zone if it hasn't already been made and return the id
        CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:ZONE_NAME];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE zoneID:zone.zoneID];
        collectionToReturn.recordId = record.recordID;
        
        // name
        collectionToReturn.name = (name != nil) ? name : [Collection randomCollectionName];
    }
    return collectionToReturn;
}

+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record {
    
    // create a Collection object in the context
    Collection *collectionToReturn = [Collection createManagedObject:context];
    if (collectionToReturn) {
        
        // objectId
        collectionToReturn.objectId = [record objectForKey:OBJECT_ID_KEY];
        
        // placement
        collectionToReturn.placement = [record objectForKey:PLACEMENT_KEY];
        
        // recordId
        collectionToReturn.recordId = record.recordID;
        
        // name
        collectionToReturn.name = [record objectForKey:NAME_KEY];
        
    }
    return collectionToReturn;
}

+ (nullable instancetype) createManagedObject: (nonnull NSManagedObjectContext *) context {
    Collection *collection = (Collection *) [NSEntityDescription insertNewObjectForEntityForName:COLLECTION_RECORD_TYPE inManagedObjectContext:context];
    return collection;
}

#pragma mark - Record Returns

-(CKRecord *) asRecord {
    CKRecord *recordToReturn;
    
    // if there is a record id (ie. there is already a record of this object
    if (self.recordId) {
        recordToReturn = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE recordID:self.recordId];
    } else {
        recordToReturn = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE];
        self.recordId = recordToReturn.recordID;
    }
    
    [recordToReturn setObject:COLLECTION_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    [recordToReturn setObject:self.objectId forKey:OBJECT_ID_KEY];
    [recordToReturn setObject:self.name forKey:NAME_KEY];
    [recordToReturn setObject:self.placement forKey:PLACEMENT_KEY];
    
    return recordToReturn;
}

-(CKRecord *) asRecordWithChanges: (NSDictionary *) dictionaryOfChanges {
    CKRecord *record;
    
    // if there is a record id (ie. there is already a record of this object
    if (self.recordId) {
        record = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE recordID:self.recordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE];
        self.recordId = record.recordID;
    }
    
    // loop through the keys in dictionaryOfChanges and build the record accordingly depending on the values stored behind those keys
    for (NSString *key in dictionaryOfChanges) {
        if (dictionaryOfChanges[key] != [NSNull null]) {
            record[key] = dictionaryOfChanges[key];
        } else {
            record[key] = nil;
        }
        [self setValue:record[key] forKey:key];
    }
    
    [record setObject:COLLECTION_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    return record;
}

# pragma mark - Update based On Record

-(void) updateBasedOnCKRecord: (nonnull CKRecord *) record {
    // objectId
    self.objectId = [record objectForKey:OBJECT_ID_KEY];
    
    // placement
    self.placement = [record objectForKey:PLACEMENT_KEY];
    
    // recordId
    self.recordId = record.recordID;
    
    // name
    self.name = [record objectForKey:NAME_KEY];
    
    // when a child Thought is deleted, it will delete its self from this thoughts set
}

# pragma mark - Utilities

// TODO - institute an array to keep track of which phrases have already been used so that the user doesn't have duplicates
+(NSString *) randomCollectionName {
    NSArray *names = [NSArray arrayWithObjects:@"Default Collection", @"Stray Thoughts", @"Extras", @"Loose Threads", @"Runaway Train", @"Lost in Translation",nil];
    int ran = arc4random_uniform((int)names.count);
    return names[ran];
}


@end

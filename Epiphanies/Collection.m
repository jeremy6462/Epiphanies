//
//  Collection.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Collection.h"

@implementation Collection

#pragma mark - Initializers

-(instancetype) initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        
        _name = (name != nil) ? name : [Collection randomCollectionName];
        _thoughts = [NSArray new];
        _objectId = [IdentifierCreator createId];
        
        _recordId = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE].recordID;
        // TODO - handle placement
    }
    return self;
}

-(instancetype) initWithRecord:(CKRecord *)record {
    self = [super init];
    if (self) {
        
        _name = [record objectForKey:NAME_KEY];
        _objectId = [record objectForKey:RECORD_ID_KEY];
        _placement = [record objectForKey:PLACEMENT_KEY];
        
        _recordId = record.recordID;
    }
    return self;
}

#pragma mark - Record Returns

-(CKRecord *) asRecord {
    CKRecord *recordToReturn;
    
    // if there is a record id (ie. there is already a record of this object
    if (_recordId) {
        recordToReturn = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE recordID:_recordId];
    } else {
        recordToReturn = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE];
        _recordId = recordToReturn.recordID;
    }
    
    [recordToReturn setObject:COLLECTION_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    [recordToReturn setObject:_objectId forKey:OBJECT_ID_KEY];
    [recordToReturn setObject:_name forKey:NAME_KEY];
    [recordToReturn setObject:_placement forKey:PLACEMENT_KEY];
    
    return recordToReturn;
}

-(CKRecord *) asRecordWithChanges: (NSDictionary *) dictionaryOfChanges {
    CKRecord *recordToReturn;
    
    // if there is a record id (ie. there is already a record of this object
    if (_recordId) {
        recordToReturn = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE recordID:_recordId];
    } else {
        recordToReturn = [[CKRecord alloc] initWithRecordType:COLLECTION_RECORD_TYPE];
    }
    
    // if there exists a key in this dictionary for any of the properties, those properties have changed, so add those properies to a new record that will be saved to CloudKit
    if ([dictionaryOfChanges objectForKey:NAME_KEY] != nil) {
        [recordToReturn setObject:dictionaryOfChanges[NAME_KEY] forKey:NAME_KEY];
        _name = recordToReturn[NAME_KEY];
    }
    if ([dictionaryOfChanges objectForKey:PLACEMENT_KEY] != nil) {
        [recordToReturn setObject:dictionaryOfChanges[PLACEMENT_KEY] forKey:PLACEMENT_KEY];
        _placement = recordToReturn[PLACEMENT_KEY];
    }
    
    [recordToReturn setObject:COLLECTION_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    return recordToReturn;
}

# pragma mark - Utilities

// TODO - institute an array to keep track of which phrases have already been used so that the user doesn't have duplicates
+(NSString *) randomCollectionName {
    NSArray *names = [NSArray arrayWithObjects:@"Default Collection", @"Stray Thoughts", @"Extras", @"Loose Threads", @"Runaway Train", @"Lost in Translation",nil];
    int ran = arc4random_uniform((int)names.count);
    return names[ran];
}

@end

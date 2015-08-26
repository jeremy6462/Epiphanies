//
//  Thought.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Thought.h"

@implementation Thought 

#pragma mark - Initializers

-(nullable instancetype) init {
    self = [super init];
    if (self) {
        _objectId = [IdentifierCreator createId];
        
        _recordId = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE zoneID:[[CKRecordZone alloc] initWithZoneName:ZONE_NAME].zoneID].recordID;
        
        _photos = [NSArray new];
        
        _placement = [NSNumber numberWithInt:0];
        
        _creationDate = [NSDate date];
    }
    return self;
}

-(instancetype) initWithRecord:(nonnull CKRecord *)record {
    self = [super init];
    if (self) {
        _objectId = [record objectForKey:OBJECT_ID_KEY];
        
        _recordId = [record recordID];
        
        _text = [record objectForKey:TEXT_KEY];
        _extraText = [record objectForKey:EXTRA_TEXT_KEY];
        _location = [record objectForKey:LOCATION_KEY];
        
        _photos = [NSArray new];
        
        _tags = [record objectForKey:TAGS_KEY];
        
        _placement = [record objectForKey:PLACEMENT_KEY]; // TODO - make sure NSNumber is returned so that it can be casted to an int
        
        _creationDate = record.creationDate;
    }
    return self;
}

-(instancetype) initWithRecord:(CKRecord *)record collection:(Collection *)collection {
    self = [self initWithRecord:record];
    self.parentCollection = collection;
    return self;
}



#pragma mark - Record Returns

- (CKRecord *) asRecord {
    
    // get a reference to self's record object. if there is none, create one
    CKRecord *record;
    if (_recordId) {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE recordID:_recordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE];
        _recordId = record.recordID;
    }
    
    [record setObject:THOUGHT_RECORD_TYPE forKey:TYPE_KEY]; // used to get the type of this record back when a change occurs and a push notification is sent
    
    // set all of the fields of the record = to the the current fields of self
    record[OBJECT_ID_KEY] = _objectId;

    record[PARENT_COLLECTION_KEY] = [[CKReference alloc] initWithRecordID:_parentCollection.recordId action:CKReferenceActionDeleteSelf];
    
    record[TEXT_KEY] = _text;
    record[EXTRA_TEXT_KEY] = _extraText;
    record[LOCATION_KEY] = _location;
    
    record[TAGS_KEY] = _tags;
    
    record[PLACEMENT_KEY] = _placement;
    
    return record;
    
}

-(CKRecord *) asRecordWithChanges:(NSDictionary *)dictionaryOfChanges {
    
    // get a reference to self's record object. if there is none, create one
    CKRecord *record;
    if (_recordId) {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE recordID:_recordId];
    } else {
        record = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE];
        _recordId = record.recordID;
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

#pragma mark - Delete Self from Parent

-(void) removeFromParent {
    
    // only attempt to remove from parent if a parent exists
    if (_parentCollection) {
        
        // an array of this photo's peers
        NSArray *sisters = _parentCollection.thoughts;
        
        // only attempt to remove if there are peer photos
        if (sisters) {
            
            NSMutableArray *mutableSisters = [NSMutableArray arrayWithArray:sisters];
            for (Thought *peer in sisters) {
                
                // disconnect self in the _parentThought.photos array
                if ([peer.objectId isEqualToString:_objectId]) {
                    [mutableSisters removeObject:peer];
                }
                
            }
            _parentCollection.thoughts = [NSArray arrayWithArray:mutableSisters];
        }
    }
    
}

@end

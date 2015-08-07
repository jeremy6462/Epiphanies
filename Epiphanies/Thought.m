//
//  Thought.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "Thought.h"

@implementation Thought : NSObject

#pragma mark - Initializers

-(nullable instancetype) initWithText: (nullable NSString *) text location: (nullable CLLocation *) location photos: (nullable NSArray<Photo *> *) photos webURL: (nullable NSString *) web telURL: (nullable NSString *) tel emailURL: (nullable NSString *) email collection: (nonnull Collection *) collection placement: (nonnull NSNumber *) placement {
    self = [super init];
    if (self) {
        _objectId = [IdentifierCreator createId];
    
        _recordId = [[CKRecord alloc] initWithRecordType:THOUGHT_RECORD_TYPE].recordID;
        
        _parentCollection = collection;
        
        _text = text;
        _location = location;
        _photos = photos;
        
        _webURL = web;
        _telURL = tel;
        _emailURL = email;
        
        [self addURLsToLinksArray];
        
        _placement = placement;
    }
    return self;
}

-(instancetype) initWithRecord:(nonnull CKRecord *)record {
    self = [super init];
    if (self) {
        _objectId = [record objectForKey:OBJECT_ID_KEY];
        
        _recordId = [record recordID];
        
        _text = [record objectForKey:TEXT_KEY];
        _location = [record objectForKey:LOCATION_KEY];
        
        _links = [record objectForKey:LINKS_KEY];
        
        [self parseURLsToProperties];
        
        _placement = [record objectForKey:PLACEMENT_KEY]; // TODO - make sure NSNumber is returned so that it can be casted to an int
    }
    return self;
}

-(instancetype) initWithRecord:(CKRecord *)record collection:(Collection *)collection {
    self = [super init];
    if (self) {
        self = [self initWithRecord:record];
        _parentCollection = collection;
    }
    return self;
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
            for (Thought *peer in mutableSisters) {
                
                // disconnect self in the _parentThought.photos array
                if ([peer.objectId isEqualToString:_objectId]) {
                    [mutableSisters removeObject:peer];
                }
                
            }
            _parentCollection.thoughts = [NSArray arrayWithArray:mutableSisters];
        }
    }
    
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
    
    // set all of the fields of the record = to the the current fields of self
    record[OBJECT_ID_KEY] = _objectId;

    record[PARENT_COLLECTION_KEY] = [[CKReference alloc] initWithRecordID:_parentCollection.recordId action:CKReferenceActionDeleteSelf];
    
    record[TEXT_KEY] = _text;
    record[LOCATION_KEY] = _location;
    
    [self addURLsToLinksArray];
    record[LINKS_KEY] = _links;
    
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
    
    // if there exists a key in this dictionary for any of the properties, those properties have changed, so add those properies to a new record that will be saved to CloudKit
    if ([dictionaryOfChanges objectForKey:TEXT_KEY] != nil) {
        if ([dictionaryOfChanges objectForKey:TEXT_KEY] == Remove) {
            [record setObject:nil forKey:TEXT_KEY];
        } else {
            [record setObject:dictionaryOfChanges[TEXT_KEY] forKey:TEXT_KEY];
        }
        _text = record[TEXT_KEY];
    }
    if ([dictionaryOfChanges objectForKey:LOCATION_KEY] != nil) { // TODO - how to handle deleting a location
        if ([dictionaryOfChanges objectForKey:LOCATION_KEY] == Remove) {
            [record setObject:nil forKey:LOCATION_KEY];
        } else {
            [record setObject:dictionaryOfChanges[LOCATION_KEY] forKey:LOCATION_KEY];
        }
        _location = record[LOCATION_KEY];
    }
    if ([dictionaryOfChanges objectForKey:PARENT_COLLECTION_KEY] != nil) {
        Collection *parent = dictionaryOfChanges[PARENT_COLLECTION_KEY];
        CKReference *reference = [[CKReference alloc] initWithRecordID:parent.recordId action:CKReferenceActionDeleteSelf];
        [record setObject:reference forKey:PARENT_COLLECTION_KEY];
        _parentCollection = dictionaryOfChanges[PARENT_COLLECTION_KEY];
    }
    if ([dictionaryOfChanges objectForKey:WEB_KEY] != nil) {
        if ([dictionaryOfChanges objectForKey:WEB_KEY] == Remove) {
            _webURL = nil;
        } else {
            _webURL = [dictionaryOfChanges objectForKey:WEB_KEY];
        }
        _webURL = record[WEB_KEY];
        [self addURLsToLinksArray];
        [record setObject:_links forKey:LINKS_KEY];
    }
    if ([dictionaryOfChanges objectForKey:TEL_KEY] != nil) {
        if ([dictionaryOfChanges objectForKey:TEL_KEY] == Remove) {
            _telURL = nil;
        } else {
            _telURL = [dictionaryOfChanges objectForKey:TEL_KEY];
        }
        _telURL = record[TEL_KEY];
        [self addURLsToLinksArray];
        [record setObject:_links forKey:LINKS_KEY];
    }
    if ([dictionaryOfChanges objectForKey:EMAIL_KEY] != nil) {
        if ([dictionaryOfChanges objectForKey:EMAIL_KEY] == Remove) {
            _emailURL = nil;
        } else {
            _emailURL = [dictionaryOfChanges objectForKey:EMAIL_KEY];
        }
        _emailURL = record[EMAIL_KEY];
        [self addURLsToLinksArray];
        [record setObject:_links forKey:LINKS_KEY];
    }
    if ([dictionaryOfChanges objectForKey:PLACEMENT_KEY] != nil) {
        [record setObject:dictionaryOfChanges[PLACEMENT_KEY] forKey:PLACEMENT_KEY];
        _placement = dictionaryOfChanges[PLACEMENT_KEY];
    }
    
    return record;
}
    
#pragma mark - URL Utilities

-(void) addURLsToLinksArray {
    _links = [NSArray new];
    if (_webURL != nil) {
        NSString *prefixedWebURL = [_webURL addPrefix:Web];
        _links = [_links arrayByAddingObject:prefixedWebURL];
    }
    if (_telURL != nil) {
        NSString *prefixedTelURL = [_telURL addPrefix:Tel];
        _links = [_links arrayByAddingObject:prefixedTelURL];
    }
    if (_emailURL != nil) {
        NSString *prefixedEmailURL = [_emailURL addPrefix:Email];
        _links = [_links arrayByAddingObject:prefixedEmailURL];
    }
}

-(void) parseURLsToProperties {
    for (NSString *link in _links) {
        Prefix prefix = [link URLTypeForPrefixedLink];
        switch (prefix) {
            case Web:
                _webURL = [link deprefixLink];
                break;
            case Tel:
                _telURL = [link deprefixLink];
                break;
            case Email:
                _emailURL = [link deprefixLink];
                break;
            default:
                break;
        }
    }
}

@end

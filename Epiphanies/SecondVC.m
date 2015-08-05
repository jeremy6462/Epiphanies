//
//  SecondVC.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 7/26/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "SecondVC.h"

@implementation SecondVC

- (void) viewDidLoad {
    
}

- (IBAction)saveManyObjects:(id)sender {
    NSArray *collectionsAndThoughts = [self getManyObjects];
    NSArray *collections = collectionsAndThoughts[0];
    NSArray *thoughts = collectionsAndThoughts[1];
    
    CKModifyRecordsOperation *operationSaveCollections = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:collections recordIDsToDelete:nil];
    operationSaveCollections.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    operationSaveCollections.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError) {
        if (operationError) {
            NSLog(@"Error saving collections: %@", operationError.userInfo[NSLocalizedDescriptionKey]);
        }
    };
    
    CKModifyRecordsOperation *operationSaveThoughts = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:thoughts recordIDsToDelete:nil];
    operationSaveThoughts.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    operationSaveThoughts.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError) {
        if (operationError) {
            NSLog(@"Error saving thoughts: %@", operationError.userInfo[NSLocalizedDescriptionKey]);
        }
    };
    
    [operationSaveThoughts addDependency:operationSaveCollections]; // make sure to save thoughts only after the collections have been saved (operationThoughts depends on operationCollections being completed)
    
    [_database addOperation:operationSaveCollections];
    [_database addOperation:operationSaveThoughts];
    
}

- (IBAction)fetchMany:(id)sender {
    if (!_database) {
       [self initializeDBs];
    }
    
    NSPredicate *allPredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    
    // Fetch all of the Collections
    
    CKQuery *queryAllCollections = [[CKQuery alloc] initWithRecordType:@"Collection" predicate:allPredicate];
    CKQueryOperation *collectionFetchOperation = [[CKQueryOperation alloc] initWithQuery:queryAllCollections];
    collectionFetchOperation.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    
    NSMutableArray *arrayCollections = [NSMutableArray new];
    [collectionFetchOperation setRecordFetchedBlock:^(CKRecord *record) {
        NSLog(@"Collection Found: %@", record[@"name"]);
        [arrayCollections addObject:record];
    }];
    
    collectionFetchOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, handle this error with such perfection that your users will never realize an error occurred.
            NSLog(@"Error fetching collections: %@", error.userInfo[NSLocalizedDescriptionKey]);
        } else {
            NSLog(@"arrayCollections: %@", arrayCollections);
        }
    };
    
    [_database addOperation:collectionFetchOperation];
    
    
    
    // Fetch all of the Thoughts
    
    CKQuery *queryAllThoughts = [[CKQuery alloc] initWithRecordType:@"Thought" predicate:allPredicate];
    CKQueryOperation *thoughtFetchOperation = [[CKQueryOperation alloc] initWithQuery:queryAllThoughts];
    thoughtFetchOperation.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    
    NSMutableArray *arrayThoughts = [NSMutableArray new];
    [thoughtFetchOperation setRecordFetchedBlock:^(CKRecord *record) {
        NSLog(@"Thought Found with Text: %@ and Parent: %@", record[@"text"], record[@"parent"]);
        [arrayThoughts addObject:record];
    }];
    
    thoughtFetchOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, handle this error with such perfection that your users will never realize an error occurred.
            NSLog(@"Error fetching thoughts: %@", error.userInfo[NSLocalizedDescriptionKey]);
        } else {
            NSLog(@"arrayThoughts: %@", arrayThoughts);
        }
    };
    
    [_database addOperation:thoughtFetchOperation];
    
}

- (IBAction)deleteRecords:(id)sender {
    if (!_zoneId) [self createZone];
    NSArray *allObjects = [self getManyObjects];
    NSArray *collections = allObjects[0];
    //        NSArray *thoughts = allObjects[1];
    
    CKModifyRecordsOperation *collectionsDeleteOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:collections];
    
    collectionsDeleteOperation.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    collectionsDeleteOperation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError) {
        if (operationError) {
            NSLog(@"Error deleting collections: %@", operationError.userInfo[NSLocalizedDescriptionKey]);
        }
    };
    
    //        CKModifyRecordsOperation *thoughtsDeleteOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:thoughts];
    //        thoughtsDeleteOperation.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    //        thoughtsDeleteOperation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError) {
    //            if (operationError) {
    //                NSLog(@"Error deleting thoughts: %@", operationError.description);
    //            }
    //        };
    
    //        [thoughtsDeleteOperation addDependency:collectionsDeleteOperation]; // make sure to save thoughts only after the collections have been saved (operationThoughts depends on operationCollections being completed)
    
    [_database addOperation:collectionsDeleteOperation];
    //        [_database addOperation:thoughtsDeleteOperation];
}


// called by saveManyObjects
- (NSArray *) getManyObjects {
    NSMutableArray *collectionsAndThoughts = [NSMutableArray new];
    
    NSMutableArray *collections = [NSMutableArray new];
    NSMutableArray *thoughts = [NSMutableArray new];
    
    CKRecordZoneID *zoneId = (_zoneId) ? _zoneId : [self createZone]; // initalizes DB's as well
    
    for (int collectionNumber = 0; collectionNumber < 2; collectionNumber++) {
        
        CKRecord *collectionRecord = [[CKRecord alloc] initWithRecordType:@"Collection" zoneID:zoneId];
        NSString *name = [NSString stringWithFormat:@"collection%d", collectionNumber];
        [collectionRecord setObject:name forKey:@"name"];
        [collections addObject:collectionRecord];
        
        for (int thoughtNumber = 0; thoughtNumber < 4; thoughtNumber++) {
            
            CKRecord *thoughtRecord = [[CKRecord alloc] initWithRecordType:@"Thought" zoneID:zoneId];
            thoughtRecord[@"text"] = [NSString stringWithFormat:@"thought%d", thoughtNumber];
            CKReference *parent = [[CKReference alloc] initWithRecord:collectionRecord action:CKReferenceActionDeleteSelf];
            thoughtRecord[@"parent"] = parent;
            [thoughts addObject:thoughtRecord];
            
        }
        
    }
    
    [collectionsAndThoughts addObject:collections]; [collectionsAndThoughts addObject:thoughts];
    
    
    NSArray *arrayToReturn = [NSArray arrayWithArray:collectionsAndThoughts];
    return arrayToReturn;
}

// called by getManyObjects
-(CKRecordZoneID *) createZone {
    [self initializeDBs];
    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"User_Zone"]; // now have a zoneID
    
    CKModifyRecordZonesOperation *zoneSave = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:@[zone]recordZoneIDsToDelete:nil];
    zoneSave.modifyRecordZonesCompletionBlock = ^(NSArray *zoneSaves, NSArray *zoneDeletes, NSError *error) {
        if (error) {
            NSLog(@"Error saving Zone: %@", error.userInfo[NSLocalizedDescriptionKey]);
        }
    };
    [_database addOperation:zoneSave];
    _zoneId = zone.zoneID;
    return zone.zoneID; // trusting that it saves successfully
}

// called by createZone
-(void) initializeDBs {
    if (!_container) {
        _container = [CKContainer defaultContainer];
    }
    if (!_database) {
        _database = [_container privateCloudDatabase];
    }
}

@end

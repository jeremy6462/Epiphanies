//
//  ZoneCreator.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/3/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "ZoneCreator.h"

@implementation ZoneCreator

+(void) createCustomZoneForDatabase:(CKDatabase *)database withCompletionHandler:(void (^)(NSArray *, NSArray *, NSError *))block {

    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"User_Zone"]; // TODO - is there a better name for this?
    
    CKModifyRecordZonesOperation *zoneSave = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:@[zone]recordZoneIDsToDelete:nil];
    zoneSave.modifyRecordZonesCompletionBlock = ^(NSArray *zoneSaves, NSArray *zoneDeletes, NSError *error) {
        block (zoneSaves, zoneDeletes, error);
    };
    [database addOperation:zoneSave];
    
    // TODO - what happens if a zone is created with an identical name (ie. this method is called twice)? I want this method to only be called once so that only one zone is created and it is on the first time that this user logs in
}

@end

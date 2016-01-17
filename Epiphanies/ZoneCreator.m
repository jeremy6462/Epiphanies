//
//  ZoneCreator.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/3/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "ZoneCreator.h"

@implementation ZoneCreator

// TODO - revert back to the old true in Defaults and try to create a CKRecordZoneID using ZONE_NAME and see if there zoneId's match

+(void) createCustomZoneForDatabase:(CKDatabase *)database withCompletionHandler:(void (^)(NSArray *, NSArray *, NSError *))block {

    if (![ZoneCreator zoneAlreadyCreated]) {
        CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:ZONE_NAME];
        
        CKModifyRecordZonesOperation *zoneSave = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:@[zone]recordZoneIDsToDelete:nil];
        zoneSave.modifyRecordZonesCompletionBlock = ^(NSArray *zoneSaves, NSArray *zoneDeletes, NSError *error) {
            if (!error && [zoneSaves count]) {
                 [ZoneCreator storeZoneId: zone.zoneID];
            }
            block (zoneSaves, zoneDeletes, error);
        };
        [database addOperation:zoneSave];
    } else {
        block(nil,nil,nil); // this means that the zone is already saved
    }

}

+(BOOL)zoneAlreadyCreated {
    return [[NSUserDefaults standardUserDefaults] objectForKey:ZONE_SAVED] != nil;
}

+(void)storeZoneId: (CKRecordZoneID *) zoneId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:ZONE_SAVED];
}

@end

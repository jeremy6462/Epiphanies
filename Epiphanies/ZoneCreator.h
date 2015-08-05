//
//  ZoneCreator.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/3/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"


@interface ZoneCreator : NSObject

/*!
 @abstract this method creates a custom zone for the current user if one has not already been created
 @discussion custome zones are used to help organize data in a CloudKit database. I am using them so that I can use their push notification update to clients that data on the private database for their user was updated, changed, or added
 @return in zoneSaves, the first property will be the zone that was saved correctly
 */
+(void) createCustomZoneForDatabase: (CKDatabase *) database withCompletionHandler:(void (^)(NSArray */*zoneSaves*/, NSArray */*zoneDeletes*/, NSError */*error*/))block;

@end

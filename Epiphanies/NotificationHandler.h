//
//  NotificationHandler.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 5/9/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface NotificationHandler : NSObject // most likely will have to specify this class to cloud kit specific notifications

/*
 @abstract Use this method to handle notifications
 @discussion This is the only public method because I want all cloud kit notification handling going through this method
 */
+ (void) handleCloudKitNotification: (CKNotification *) cloudKitNotification;

/*
 @abstract fetches all notifications and mark them as handled in the database
 @discussion this should be called once, the first time the application is run so that all the past notifications are entered into the database and marked as previously handled
 */
+ (void) enterAllNotificationsToDatabase;

+ (BOOL) readyToProcessNewNotifications;

@end

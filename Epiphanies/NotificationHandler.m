//
//  NotificationHandler.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 5/9/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import "NotificationHandler.h"

@implementation NotificationHandler

/*
 @abstract A class method to handle notifiation
 @discussion Purpose - so calling class (most likely AppDelegate) doesn't have to instantiate at an instance of this object. We want an instance because we want to be able to store a mutable array of all the notifications seen to mark as read
 */
+ (void) handleCloudKitNotification: (CKNotification *) cloudKitNotification {
    [[NotificationHandler new] handleCloudKitNotification:cloudKitNotification];
}

NSMutableArray<CKNotificationID *>* processedNotificationIDs;

- (instancetype) init {
    self = [super init];
    if (self) {
        processedNotificationIDs = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Notification Completion Block Type Declarations
typedef void (^NotificationChangeBlock)(CKNotification *notification);
typedef void (^NotificationChangeCompletionBlock)(CKServerChangeToken *serverChangeToken, NSError *operationError);

- (NotificationChangeBlock) notificationChangeBlock {
        
    return ^void(CKNotification *notification) {
        
        if (notification.notificationType == CKNotificationTypeQuery
            || ![NotificationHandler notificationHandledPreviously:notification]) { // only process the unread notifications
    
            [processedNotificationIDs addObject:notification.notificationID];
            [NotificationHandler markAsHandledInDatabase:notification];
            [NotificationHandler updateBasedOnNotification: (CKQueryNotification *)notification];
            
        }
    };
}

- (NotificationChangeCompletionBlock) notificationChangeCompletionBlock: (CKFetchNotificationChangesOperation *) operation {
    
    return ^void(CKServerChangeToken *serverChangeToken, NSError *operationError) {
        if (operationError) {
            NSLog(@"Error on notificationChangeCompletionBlock: %@", operationError);
        } else {
            CKMarkNotificationsReadOperation *operationMarkAsRead = [NotificationHandler markAsRead:processedNotificationIDs];
            [[Model sharedInstance] executeContainerOperation:operationMarkAsRead];
            [processedNotificationIDs removeAllObjects];
        }
    };

}

- (void) handleCloudKitNotification: (CKNotification *) cloudKitNotification {
    
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        
        // process the fetched record for the initial notifiaction
        [NotificationHandler updateBasedOnNotification:(CKQueryNotification *)cloudKitNotification];
        [NotificationHandler markAsHandledInDatabase:cloudKitNotification];
        
        // fetch any possibly missed notifications
        CKFetchNotificationChangesOperation *operationFetchMissing = [CKFetchNotificationChangesOperation new];
        operationFetchMissing.notificationChangedBlock = [self notificationChangeBlock];
        operationFetchMissing.fetchNotificationChangesCompletionBlock = [self notificationChangeCompletionBlock:operationFetchMissing];
        operationFetchMissing.qualityOfService = NSOperationQualityOfServiceBackground;
        
        // mark the initial noticiation as read so it is not taken in multiple times
        CKMarkNotificationsReadOperation *operationMarkAsRead = [NotificationHandler markAsRead:@[cloudKitNotification.notificationID]];
        
        // add dependancy that the operationMarkAsRead is executed before the operationFetchMissing so that the initial notification isn't processed in the fetch notificationChangedBlock
        [operationFetchMissing addDependency:operationMarkAsRead];
        
        // execute the operations
        [[Model sharedInstance] executeContainerOperation:operationMarkAsRead];
        [[Model sharedInstance] executeContainerOperation:operationFetchMissing];
    
    }

}

+ (void) updateBasedOnNotification:(CKQueryNotification *) notification {
    
    CKRecordID *fetchedRecordId = [notification recordID];
    switch (notification.queryNotificationReason) {
        case CKQueryNotificationReasonRecordDeleted:
            // TODO - optomize this - we don't have the type of this record, all we have is the recordID (we requested the recordType in the desired keys when asking for the notification, however desiredKeys is not returned to us when Reason = Deleted)
            // Below is terrible code. I know that. But until I get my desiredKeys from CloudKit, there is no way to know the type of record, so I'm forced to attempt to delete the record from Collection, Thought, and Photo and one should work.
            [[Model sharedInstance] deleteObjectFromCoreDataWithRecordId:fetchedRecordId withType:COLLECTION_RECORD_TYPE];
            [[Model sharedInstance] deleteObjectFromCoreDataWithRecordId:fetchedRecordId withType:THOUGHT_RECORD_TYPE];
            [[Model sharedInstance] deleteObjectFromCoreDataWithRecordId:fetchedRecordId withType:PHOTO_RECORD_TYPE];
            break;
        default: // creation or update
            [[Model sharedInstance] fetchCKRecordAndUpdateCoreData:fetchedRecordId];
            break;
    }

}

+ (CKMarkNotificationsReadOperation *) markAsRead: (NSArray<CKNotificationID *> *) notificationIDs {
    CKMarkNotificationsReadOperation *operationMarkRead = [[CKMarkNotificationsReadOperation alloc] initWithNotificationIDsToMarkRead:notificationIDs];
    operationMarkRead.qualityOfService = NSOperationQualityOfServiceBackground;
    operationMarkRead.markNotificationsReadCompletionBlock = ^void(NSArray <CKNotificationID *> * _Nullable notificationIDsMarkedRead, NSError * _Nullable markOperationError) {
        if (markOperationError) {
           NSLog(@"Error marking notifciations as read: %@", markOperationError); 
        }
    };
    return operationMarkRead;
}

#pragma mark - Notification Handling Database

+ (void) enterAllNotificationsToDatabase {
    CKFetchNotificationChangesOperation *operation = [CKFetchNotificationChangesOperation new];
    operation.notificationChangedBlock = ^void(CKNotification *notification) {
        [NotificationHandler markAsHandledInDatabase:notification];
    };
    operation.fetchNotificationChangesCompletionBlock = ^void(CKServerChangeToken *serverChangeToken, NSError *operationError) {
        [NotificationHandler setReadyToProcessNewNotifications];
    };
    operation.qualityOfService = NSOperationQualityOfServiceBackground;
    [[Model sharedInstance] executeContainerOperation:operation];
}

+ (void) markAsHandledInDatabase:(CKNotification *) notification {
    NSString* UUID = [NotificationHandler getIDFromNotification:notification];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:UUID];
}

+ (BOOL) notificationHandledPreviously: (CKNotification *) notification {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[NotificationHandler getIDFromNotification:notification]] isEqual: @YES];
}

+ (NSString* ) getIDFromNotification: (CKNotification *) notification {
    NSRange rangeOfUUID = [notification.notificationID.description  rangeOfString:@"UUID="];
    int indexOfID = (int)(rangeOfUUID.location + rangeOfUUID.length);
    NSString *carrotOnEnd = [notification.notificationID.description substringFromIndex:indexOfID];
    return [carrotOnEnd substringToIndex:carrotOnEnd.length-1];
}

+ (void) setReadyToProcessNewNotifications {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:READY_TO_PROCESS_NOTIFICATIONS];
}

+ (BOOL) readyToProcessNewNotifications {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:READY_TO_PROCESS_NOTIFICATIONS] isEqual: @YES];
}

@end

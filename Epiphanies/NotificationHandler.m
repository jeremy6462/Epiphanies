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
        
        if (notification.notificationType == CKNotificationTypeQuery) {
    
            [processedNotificationIDs addObject:notification.notificationID];
            NSLog(@"added notificationID %@", notification.notificationID.description);
            
            //        if (notification.notificationType == CKNotificationTypeQuery) {
            //            CKQueryNotification *ckQueryNotification = (CKQueryNotification *)notification;
            //            CKRecordID *fetchedRecordId = [ckQueryNotification recordID];
            //            [[Model sharedInstance] fetchCKRecordAndUpdateCoreData:fetchedRecordId]; // possibly use desiredKeys to save a few requests (on the subscription side)
            //            // TODO - update the view controller - maybe using notification center
            //        }
            
        }
        
    };

}

- (NotificationChangeCompletionBlock) notificationChangeCompletionBlock: (CKFetchNotificationChangesOperation *) operation {
    
//    __weak CKFetchNotificationChangesOperation *operationLocal = operation;
    
    return ^void(CKServerChangeToken *serverChangeToken, NSError *operationError) {
        if (operationError) {
            NSLog(@"Error on notificationChangeCompletionBlock: %@", operationError);
        } else {
            NSLog(@"about to mark notifcations as read: %@", processedNotificationIDs.description);
            CKMarkNotificationsReadOperation *operationMarkAsRead = [NotificationHandler markAsRead:processedNotificationIDs];
            [[Model sharedInstance] executeContainerOperation:operationMarkAsRead];
            [processedNotificationIDs removeAllObjects];
            
//            if (operationLocal.moreComing) {
//                NSLog(@"More notifications to come");
//                // use same blocks on a new operation?
//            }
        }
    };

}

- (void) handleCloudKitNotification: (CKNotification *) cloudKitNotification {
    
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        
        // mark the initial noticiation as read so it is not taken in multiple times
        NSLog(@"About to mark initial notification as read %@", cloudKitNotification.notificationID.description);
        NSLog(@"Initial ID: %@ Type: %ld", cloudKitNotification.notificationID.description, (long)cloudKitNotification.notificationType);
        CKMarkNotificationsReadOperation *operationMarkAsRead = [NotificationHandler markAsRead:@[cloudKitNotification.notificationID]];
        
//        // process the fetched record for the initial notifiaction
//        CKQueryNotification *ckQueryNotification = (CKQueryNotification *)cloudKitNotification;
//        CKRecordID *fetchedRecordId = [ckQueryNotification recordID];
//        [[Model sharedInstance] fetchCKRecordAndUpdateCoreData:fetchedRecordId];
        
        // fetch any possibly missed notifications
        CKFetchNotificationChangesOperation *operationFetchMissing = [CKFetchNotificationChangesOperation new];
        operationFetchMissing.notificationChangedBlock = [self notificationChangeBlock];
        operationFetchMissing.fetchNotificationChangesCompletionBlock = [self notificationChangeCompletionBlock:operationFetchMissing];
        operationFetchMissing.qualityOfService = NSOperationQualityOfServiceBackground;
        
        // add dependancy that the operationMarkAsRead is executed before the operationFetchMissing so that the initial notification isn't processed in the fetch notificationChangedBlock
        [operationFetchMissing addDependency:operationMarkAsRead];
        
        // execute the operations
        [[Model sharedInstance] executeContainerOperation:operationMarkAsRead];
        [[Model sharedInstance] executeContainerOperation:operationFetchMissing];
    
    }

}

+ (CKMarkNotificationsReadOperation *) markAsRead: (NSArray<CKNotificationID *> *) notificationIDs {
    CKMarkNotificationsReadOperation *operationMarkRead = [[CKMarkNotificationsReadOperation alloc] initWithNotificationIDsToMarkRead:notificationIDs];
    operationMarkRead.qualityOfService = NSOperationQualityOfServiceBackground;
    operationMarkRead.markNotificationsReadCompletionBlock = ^void(NSArray <CKNotificationID *> * _Nullable notificationIDsMarkedRead, NSError * _Nullable markOperationError) {
        if (markOperationError) {
           NSLog(@"Error marking notifciations as read: %@", markOperationError); 
        }
        NSLog(@"Notifications successfully marked read: %@", notificationIDsMarkedRead.description);
    };
    return operationMarkRead;
}

@end

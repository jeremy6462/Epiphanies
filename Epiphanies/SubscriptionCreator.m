//
//  SubscriptionCreator.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/3/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "SubscriptionCreator.h"

@implementation SubscriptionCreator

+(void)addSubscriptionsToDatabase:(CKDatabase *)database withCompletionHandler:(void (^)(BOOL, NSError *))block {
    
    // check that the user hasn't already subscribed to CloudKit
    if (![self isSubscribed]) {
        // predicate that will ask for all records
        NSPredicate *allPredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
        
        // subscriptions that will send the client notifications when objects are changed, added, and created
        CKSubscription *collectionSubscription = [[CKSubscription alloc] initWithRecordType:COLLECTION_RECORD_TYPE predicate:allPredicate
                                                                                    options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate | CKSubscriptionOptionsFiresOnRecordDeletion];
        CKSubscription *thoughtSubscription = [[CKSubscription alloc] initWithRecordType:THOUGHT_RECORD_TYPE predicate:allPredicate
                                                                                 options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate | CKSubscriptionOptionsFiresOnRecordDeletion];
        CKSubscription *photoSubscription = [[CKSubscription alloc] initWithRecordType:PHOTO_RECORD_TYPE predicate:allPredicate
                                                                               options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate | CKSubscriptionOptionsFiresOnRecordDeletion];
        
        // a notifiation object to detail the type of notification to relay to the client upon subscription finding new data
        CKNotificationInfo *notification = [CKNotificationInfo new];
        notification.shouldSendContentAvailable = YES;
        notification.desiredKeys = @[TYPE_KEY]; // include the type of record that was pushed so that we can determine how to query for it
        
        // add the notification to the subscriptions
        collectionSubscription.notificationInfo = notification;
        thoughtSubscription.notificationInfo = notification;
        photoSubscription.notificationInfo = notification;
        
        // save the subscriptions to the database TODO - better error handling system for multiple subscriptions
        [database saveSubscription:collectionSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {}];
        [database saveSubscription:thoughtSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {}];
        [database saveSubscription:photoSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
            if (error) {
                block(NO, error);
            } else {
                [self subscribeInDefaults];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    block(YES, nil);
                });
            }
        }];
        
    } else { // if the user was already subscribed to CloudKit
        block(NO,nil);
    }
    
}

+(BOOL)isSubscribed {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SUBSCRIPTION_KEY] != nil;
}

+(void)subscribeInDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:SUBSCRIPTION_KEY];
}

@end

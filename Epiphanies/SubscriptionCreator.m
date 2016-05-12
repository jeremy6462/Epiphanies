//
//  SubscriptionCreator.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/3/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "SubscriptionCreator.h"

@implementation SubscriptionCreator

// TODO - TEST THAT THIS ACTUALLY SAVES A SUBSCRIPTION test what happens when subscriptions are added twice
+(void)addSubscriptionsToDatabase:(CKDatabase *)database withCompletionHandler:(void (^)(BOOL, NSError *))block {
    
    // check that the user hasn't already subscribed to CloudKit
    if (![self isSubscribed]) {
        
        // check if there is already a subscripiton for this device
        [database fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
            if ([subscriptions count] % 3 != 0) { // if for each of the devices, the count of subscriptions isn't a multiple of 3
                [SubscriptionCreator subscribe:database withCompletionHandler:block];
            } else {
                [SubscriptionCreator setSubscriptionInDefaults:YES];
                block(NO, nil);
            }
        }];
        
    } else { // if the user was already subscribed to CloudKit
        block(NO,nil);
    }
    
}

+ (void) subscribe:(CKDatabase *)database withCompletionHandler:(void (^)(BOOL, NSError *))block {
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
    
    //TODO - not sure if we need you anymore. If anything, objectId
    notification.desiredKeys = @[TYPE_KEY]; // include the type of record that was pushed so that we can determine how to query for it
    
    // add the notification to the subscriptions
    collectionSubscription.notificationInfo = notification;
    thoughtSubscription.notificationInfo = notification;
    photoSubscription.notificationInfo = notification;
    
    // save the subscriptions to the database TODO - better error handling system for multiple subscriptions
    [database saveSubscription:collectionSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) {
            [SubscriptionCreator setSubscriptionInDefaults:NO];
            block(NO, error);
        }
    }];
    [database saveSubscription:thoughtSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) {
            [SubscriptionCreator setSubscriptionInDefaults:NO];
            block(NO, error);
        }
    }];
    [database saveSubscription:photoSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
        if (error) {
            [SubscriptionCreator setSubscriptionInDefaults:NO];
            block(NO, error);
        } else {
            [SubscriptionCreator setSubscriptionInDefaults:YES];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                block(YES, nil); // TODO - I would like to add depenedancy managment in order to make sure that the photo subscription is the last one that saves. If there is no dependancy, I don't know when to run the block b/c we don't know which subscritpiton will finish saving first
            });
        }
    }];
}


+ (BOOL) isSubscribed {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SUBSCRIPTION_KEY] isEqual: @YES];
}

+ (void) setSubscriptionInDefaults:(BOOL) subscribe {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:subscribe forKey:SUBSCRIPTION_KEY];
}

@end

//
//  SubscriptionCreator.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/3/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"
#import "ForFundamentals.h"

#define SUBSCRIPTION_KEY @"subscribed"

@interface SubscriptionCreator : NSObject

/*!
 @abstract register this device for a subscription to CloudKit
 @discussion after first subscription, the fact that the user subscribed is noted in user defaults. If this method is called again (after subscription), the user will not subscribe again. Success will be NO and error will be nil.
 */
+(void)addSubscriptionsToDatabase: (CKDatabase *) database withCompletionHandler:(void(^)(BOOL success, NSError *error))block;

@end

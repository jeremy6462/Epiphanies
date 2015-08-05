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

@interface SubscriptionCreator : NSObject

-(void)addSubscriptionsToDatabase: (CKDatabase *) database withCompletionHandler:(void(^)(BOOL success, NSError *error))block

@end

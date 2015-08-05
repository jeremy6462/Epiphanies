//
//  Deleter.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/4/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Deleter.h"

@implementation Deleter

-(void) deleteRecord:(CKRecordID *)recordId onDatabase:(CKDatabase *)database withCompletionHandler:(void (^)(CKRecordID *, NSError *))block {
    [database deleteRecordWithID:recordId completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) {
            // In your app, handle this error. Please.
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        } else {
            NSLog(@"Successfully deleted record");
        }
    }];
}


@end

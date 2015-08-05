//
//  Deleter.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/4/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"
#import "FundementalObjectHeaders.h"
#import "ForFundamentals.h"

@interface Deleter : NSObject

/*!
 @abstract deletes a record present on a database
 @param recordId the identifier of the record to delete
 @param database the databse to delete the from
 */
- (void)deleteRecord:(CKRecordID *)recordId onDatabase: (CKDatabase *) database withCompletionHandler: (void(^)(CKRecordID *deletedId, NSError *error))block;

@end

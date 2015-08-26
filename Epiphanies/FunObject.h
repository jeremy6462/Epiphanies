//
//  FunObject.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/2/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"

@protocol FunObject <NSObject>

@property (nullable, nonatomic, strong) CKRecordID *recordId;

-(nonnull CKRecord *) asRecord;

/*!
 @param dictionaryOfChanges is a dictionary where keys are record property keys (stored in ForFundamentals.h) and values are the values to change to. If the value is Remove (the RemovePropertyKey defined above) then remove that property
 */
-(nonnull CKRecord *) asRecordWithChanges:(nonnull NSDictionary *)dictionaryOfChanges;

@end

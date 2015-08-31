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

/*!
 @abstract creates a mangaged object that is of the correct type. Used in init methods to utilize Core Data and saving objects into the context
 */
+(nullable instancetype) createManagedObject: (nonnull NSManagedObjectContext *) context;

/*!
 @abstract creates a new object that is based on a CKRecord
 */
+ (nullable instancetype) newManagedObjectInContext: (nonnull NSManagedObjectContext *) context basedOnCKRecord: (nonnull CKRecord *) record;

-(nonnull CKRecord *) asRecord;

/*!
 @param dictionaryOfChanges is a dictionary where keys are record property keys (stored in ForFundamentals.h) and values are the values to change to. If the value is Remove (the RemovePropertyKey defined above) then remove that property
 */
-(nonnull CKRecord *) asRecordWithChanges:(nonnull NSDictionary *)dictionaryOfChanges;

/*!
 @abstract updates properties based on the properties fetched from CloudKit
 */
-(void) updateBasedOnCKRecord: (nonnull CKRecord *) record;

@end

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

typedef void (^DeleteRecordFromCloudKit)(CKRecordID * __nullable recordID, NSError * __nullable error);

#pragma mark - Cloud Kit

/*!
 @abstract deletes a child from it's parent's set (by calling removeFromParentsChildern: ) and deletes the object from cloudkit (by calling deleteRecord: )
 */
+(void) deleteObjectFromCloudKit: (nonnull id<FunObject>) object onDatabase:(nonnull CKDatabase *) database withCompletionHandler:(nullable DeleteRecordFromCloudKit)block;

/*!
 @abstract deletes a record present on a database
 @discussion delete a parent and all of it's children are deleted as well
 @param recordId the identifier of the record to delete
 @param database the databse to delete the from
 */
+ (void) deleteRecord:(nonnull CKRecordID *)recordId onDatabase:(nonnull CKDatabase *)database withCompletionHandler:(nullable DeleteRecordFromCloudKit)block ;

#pragma mark - Core Data

+ (void)deleteObject:(nonnull id<FunObject>) object context: (nonnull NSManagedObjectContext *) context;

+ (void) deleteObjectWithRecordId:(nonnull CKRecordID *) recordId context :(nonnull NSManagedObjectContext *)context type:(nonnull NSString *)recordType;

#pragma mark - Utilities

/*!
 @abstract removes a child from it's parent's array of childer (ie. Photo from parent Thought's photos array)
 */
+ (void) removeFromParentsChildren: (id<Child>) child;


@end

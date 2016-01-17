//
//  Deleter.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/4/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Deleter.h"
#import "Fetcher.h"
#import "Saver.h"

@implementation Deleter

#pragma mark - Cloud Kit

+(void) deleteObjectFromCloudKit: (nonnull id<FunObject>) object onDatabase:(nonnull CKDatabase *) database withCompletionHandler:(nullable DeleteRecordFromCloudKit)block {
    
    // remove the object from parent
    if ([object respondsToSelector:@selector(removeFromParent)]) {
        id<Child> child = (id<Child>) object;
        [Deleter removeFromParentsChildren:child];
    }
    
    [Deleter deleteRecord:object.recordId onDatabase:database withCompletionHandler:block];
}

+ (void) deleteRecord:(nonnull CKRecordID *)recordId onDatabase:(nonnull CKDatabase *)database withCompletionHandler:(nullable DeleteRecordFromCloudKit)block {
    
    [database deleteRecordWithID:recordId completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) {
            // In your app, handle this error. Please.
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            block(recordId, error);
        } else {
            NSLog(@"Successfully deleted record");
            block(recordId, error);
        }
    }];
}

#pragma mark - Core Data

+ (void) deleteObject:(nonnull id<FunObject>)object context:(nonnull NSManagedObjectContext *)context {
    [context deleteObject:object];
    [Saver saveContext:context];
}

+ (void) deleteObjectWithRecordId:(nonnull CKRecordID *) recordId context :(nonnull NSManagedObjectContext *)context type:(nonnull NSString *)recordType {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",RECORD_NAME_KEY, recordId.recordName];
    NSArray *objects = [Fetcher fetchRecordsFromCoreDataContext:context type:recordType predicate:predicate sortDescriptiors:nil];
    if ([objects count]) {
        [Deleter deleteObject:objects[0] context:context];
    }
}

#pragma mark - Utilities

+ (void) removeFromParentsChildren: (id<Child>) child {
    [child removeFromParent];
}


@end

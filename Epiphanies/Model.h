//
//  Model.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/15/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"
#import "CloudAccessors.h"

@interface Model : NSObject

@property (nonnull, nonatomic, strong) CKContainer *container;
@property (nonnull, nonatomic, strong) CKDatabase *database;
@property (nullable, nonatomic, strong) CKRecordZoneID *zoneId;

@property (nonatomic, strong) Fetcher *fetcher;
@property (nonatomic, strong) Saver *saver;
@property (nonatomic, strong) Deleter *deleter;

#pragma mark - Saving

-(void) saveThought: (Thought *) thought withPerRecordProgressBlock: (nullable void(^)(CKRecord *record, double progress)) perRecordProgressBlock
                                       withPerRecordCompletionBlock: (nullable void(^)(CKRecord * __nullable record, NSError * __nullable error)) perRecordCompletionBlock
                                                withCompletionBlock: (nonnull void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError)) modifyRecordsCompletionBlock;



#pragma mark - Fetching

/*!
 @abstract loads in all of the current user's collections (fully populated) so the view controller can use updated data
 */
- (void) reloadWithCompletion:(void(^)(NSArray<Collection *> *populatedCollections, NSError *error))block;


// add notification creator for a general object and save

@end

//
//  Photo+CoreDataProperties.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/31/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *placement;
@property (nullable, nonatomic, retain) id recordId;
@property (nullable, nonatomic, retain) NSString *recordName;
@property (nullable, nonatomic, retain) Thought *parentThought;

@end

NS_ASSUME_NONNULL_END

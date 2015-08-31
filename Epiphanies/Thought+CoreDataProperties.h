//
//  Thought+CoreDataProperties.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/31/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Thought.h"

NS_ASSUME_NONNULL_BEGIN

@interface Thought (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSString *extraText;
@property (nullable, nonatomic, retain) id location;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *placement;
@property (nullable, nonatomic, retain) id recordId;
@property (nullable, nonatomic, retain) id tags;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *reminderDate;
@property (nullable, nonatomic, retain) NSString *recordName;
@property (nullable, nonatomic, retain) Collection *parentCollection;
@property (nullable, nonatomic, retain) NSSet<Photo *> *photos;

@end

@interface Thought (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet<Photo *> *)values;
- (void)removePhotos:(NSSet<Photo *> *)values;

@end

NS_ASSUME_NONNULL_END

//
//  Collection+CoreDataProperties.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/17/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Collection.h"

NS_ASSUME_NONNULL_BEGIN

@interface Collection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSNumber *placement;
@property (nullable, nonatomic, retain) id recordId;
@property (nullable, nonatomic, retain) NSString *recordName;
@property (nullable, nonatomic, retain) NSData *recordData;
@property (nullable, nonatomic, retain) NSSet<Thought *> *thoughts;

@end

@interface Collection (CoreDataGeneratedAccessors)

- (void)addThoughtsObject:(Thought *)value;
- (void)removeThoughtsObject:(Thought *)value;
- (void)addThoughts:(NSSet<Thought *> *)values;
- (void)removeThoughts:(NSSet<Thought *> *)values;

@end

NS_ASSUME_NONNULL_END

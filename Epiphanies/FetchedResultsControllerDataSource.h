//
//  FetchedResultsControllerDataSource.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 12/28/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
@import UIKit;

@protocol FetchedResultsControllerDataSourceDelegate // protocol that each view controller utilizing FRCDataSource will comply to

- (void)configureCell:(nullable UITableViewCell*)cell withObject:(nullable id<FunObject>)object;
@optional - (void)deleteObject:(nonnull id<FunObject>)object;

@end

@interface FetchedResultsControllerDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) id<FetchedResultsControllerDataSourceDelegate> delegate;
@property (nonatomic, copy) NSString* reuseIdentifier; // TODO - research copy (just in case of mutablility?)

- (id)initWithTableView:(UITableView*)tableView;


@end

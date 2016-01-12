//
//  CollectionsViewController.h
//  
//
//  Created by Jeremy Kelleher on 1/10/16.
//
//

#import <UIKit/UIKit.h>
#import "TableViewFetchedResultsControllerDataSource.h"
#import "Reorderer.h"
#import "CollectionCell.h"

@interface CollectionsViewController : UITableViewController <TableViewFetchedResultsControllerDataSourceDelegate, NSFetchedResultsControllerDelegate, ReordererDelegate>

@property (nonatomic, weak) Model *model;

@property (nonatomic, strong) Reorderer *reorderer;

@property (nonatomic, strong) NSFetchedResultsController *collectionsFetchedResultsController;
@property (nonatomic, strong) TableViewFetchedResultsControllerDataSource *collectionsFetchedResultsControllerDataSource;

@end

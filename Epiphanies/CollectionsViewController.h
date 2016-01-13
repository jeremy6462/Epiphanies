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
#import "Updater.h"

@protocol CollectionViewControllerDelegate <NSObject>

-(void) collectionsUpdatedDuringEditing;

@end

@interface CollectionsViewController : UIViewController <UITableViewDelegate,TableViewFetchedResultsControllerDataSourceDelegate, NSFetchedResultsControllerDelegate, ReordererDelegate>

@property (nonatomic, weak) id<CollectionViewControllerDelegate> delegate;

@property (nonatomic, weak) Model *model;

@property (nonatomic, strong) NSFetchedResultsController *collectionsFetchedResultsController;
@property (nonatomic, strong) TableViewFetchedResultsControllerDataSource *collectionsFetchedResultsControllerDataSource;

@property (nonatomic, strong) Reorderer *reorderer;

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

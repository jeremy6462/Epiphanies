//
//  MainViewController.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "FetchedResultsControllerDataSource.h"

@interface MainViewController : UIViewController <UITableViewDelegate, FetchedResultsControllerDataSourceDelegate>

@property (strong, nonatomic) Model *model;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) FetchedResultsControllerDataSource *fetchedResultsControllerDataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

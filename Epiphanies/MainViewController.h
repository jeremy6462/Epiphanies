//
//  MainViewController.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Model *model;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *thoughtsTableView;

@end

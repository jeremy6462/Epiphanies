//
//  MainViewController.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "TableViewFetchedResultsControllerDataSource.h"
#import "AKPickerView.h"
#import "AKPickerViewFRCDataSource.h"
#import "PopupViewController1.h"
#import <STPopup/STPopup.h>
#import "Reorderer.h"



@interface MainViewController : UIViewController <UITableViewDelegate, TableViewFetchedResultsControllerDataSourceDelegate, NSFetchedResultsControllerDelegate, AKPickerViewDelegate, ReordererDelegate>

@property (strong, nonatomic) Model *model;

@property (strong, nonatomic) NSFetchedResultsController *thoughtsFetchedResultsController;
@property (strong, nonatomic) TableViewFetchedResultsControllerDataSource *thoughtsFetchedResultsControllerDataSource;

@property (strong, nonatomic) NSFetchedResultsController *collectionsFetchedResultsController;
@property (strong, nonatomic) AKPickerViewFRCDataSource *collectionsFetchedResultsControllerDataSource;

@property (strong, nonatomic) Reorderer *reorder;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AKPickerView *pickerView;

@end

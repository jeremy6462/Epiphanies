//
//  CollectionsViewController.m
//  
//
//  Created by Jeremy Kelleher on 1/10/16.
//
//

#import "CollectionsViewController.h"

@implementation CollectionsViewController

#pragma mark - View Controller

-(void) viewDidLoad {
    
    self.model = [Model sharedInstance];
    
    [self initalizeCollectionFetchedResultsControllerDataSource];
    
    self.reorderer = [[Reorderer alloc] init];
    self.reorderer.delegate = self;
    
    self.tableView.delegate = self;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCollection:)];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    UILongPressGestureRecognizer *reorderGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:reorderGesture];
}

-(void) viewDidDisappear:(BOOL)animated {
    [self.delegate collectionsUpdatedDuringEditing];
}

#pragma mark - Collection Fetched Results Controller

- (void) initalizeCollectionFetchedResultsControllerDataSource {
    self.collectionsFetchedResultsControllerDataSource = [[TableViewFetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];
    self.collectionsFetchedResultsControllerDataSource.fetchedResultsController = self.collectionsFetchedResultsController;
    self.collectionsFetchedResultsControllerDataSource.reuseIdentifier = @"CollectionCell";
    self.collectionsFetchedResultsControllerDataSource.delegate = self;
}

- (NSFetchedResultsController *)collectionsFetchedResultsController {
    
    if (_collectionsFetchedResultsController != nil) {
        return _collectionsFetchedResultsController;
    }
    NSManagedObjectContext *context = _model.context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:COLLECTION_RECORD_TYPE];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:PLACEMENT_KEY ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:20];
    
    _collectionsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return _collectionsFetchedResultsController;
}

- (void)configureCell:(nullable UITableViewCell*)cell withObject:(nullable Collection *)object {
    cell.textLabel.text = object.name;
}

- (void) deleteObject:(Collection *)object {
    [Collection updatePlacementForDeletionOfCollection:object inCollections:self.collectionsFetchedResultsController.fetchedObjects];
    [_model deleteFromBothCloudKitAndCoreData:object];
}

#pragma mark - Add

// should be connected through code to an added UIBarButtonItem
- (IBAction)addCollection:(id)sender {
    NSNumber* numCollections = [NSNumber numberWithInt: (int) self.collectionsFetchedResultsController.fetchedObjects.count];
    [self presentViewController: [[Updater new] handleCollectionAdditionWithPlacement:numCollections] animated:YES completion:nil];
}

#pragma mark - Update

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Collection *selectedCollection = [self.collectionsFetchedResultsController objectAtIndexPath:indexPath];
    [self presentViewController:[[Updater new] handleUpdatingCollection:selectedCollection] animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Reorderer Delegate

-(IBAction)longPressGestureRecognized:(id)sender {
    [self.reorderer longPressGestureRecognized:sender onTableView:self.tableView];
}

-(void)updatePlacementWithSource:(NSIndexPath *)sourceIndexPath destination:(NSIndexPath *)destinationIndexPath {
    
    Collection *objectMoving = [self.collectionsFetchedResultsController objectAtIndexPath:sourceIndexPath];
    Collection *objectBeingMoved = [self.collectionsFetchedResultsController objectAtIndexPath:destinationIndexPath];
    
    NSNumber* sourcePlacement = objectMoving.placement;
    NSNumber* destinationPlacement = objectBeingMoved.placement;
    
    objectMoving.placement = destinationPlacement;
    objectBeingMoved.placement = sourcePlacement;
}

@end

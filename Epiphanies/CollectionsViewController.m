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
    [_model deleteFromBothCloudKitAndCoreData:object]; // saves context
}

#pragma mark - Add

- (IBAction)addCollection:(id)sender {
    int numCollections = (int) self.collectionsFetchedResultsController.fetchedObjects.count;
    Collection *newCollection = [Collection newCollectionInManagedObjectContext:self.model.context name:nil];
    newCollection.placement = [NSNumber numberWithInteger:numCollections];
    CollectionCell *cell = (CollectionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.collection = newCollection; // get rid of it 
    [cell.textField becomeFirstResponder];
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

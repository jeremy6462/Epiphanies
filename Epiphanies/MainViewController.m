//
//  MainViewController.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

#pragma mark - View Controller

-(void) viewDidLoad {
    _model = [Model sharedInstance];
    
    [self initalizeCollectionPickerView];
    [self initalizeThoughtsFetchedResultsControllerDataSource];
    
    self.reorderer = [[Reorderer alloc] init];
    self.reorderer.delegate = self;
    
    self.tableView.delegate = self;
    
    UILongPressGestureRecognizer *reorderGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:reorderGesture];
}

- (void) viewWillAppear:(BOOL)animated {
    
    if (self.collectionsFetchedResultsController.fetchedObjects.count == 0) {
        Collection *defaultCollection = [self createDefaultCollection];
        [self updateThougthsFRCWithCollection:defaultCollection];
    }
}

#pragma mark - Picker View

- (void) initalizeCollectionPickerView {
    self.pickerView.delegate = self;
    self.pickerView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.pickerView.highlightedFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    self.pickerView.textColor = [UIColor grayColor];
    self.pickerView.highlightedTextColor = [UIColor blackColor];
    self.pickerView.interitemSpacing = 10;
    self.pickerView.fisheyeFactor = 0.0001;
    self.pickerView.pickerViewStyle = AKPickerViewStyle3D;
    
    [self initalizeCollectionFetchedResultsControllerDataSource];
    
    [self.pickerView reloadData];
}

- (void) pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item {
    Collection *collectionSelected = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
    [self updateThougthsFRCWithCollection:collectionSelected];
}

- (void) collectionsUpdatedDuringEditing {
    [self.collectionsFetchedResultsController performFetch:NULL];
    [self.pickerView reloadData];
    Collection *collectionSelected = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:self.pickerView.selectedItem inSection:0]];
    [self updateThougthsFRCWithCollection:collectionSelected];
}

#pragma mark - Thoughts Fetched Results Controller

- (void) initalizeThoughtsFetchedResultsControllerDataSource {
    self.thoughtsFetchedResultsControllerDataSource = [[TableViewFetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];
    self.thoughtsFetchedResultsControllerDataSource.fetchedResultsController = self.thoughtsFetchedResultsController;
    self.thoughtsFetchedResultsControllerDataSource.reuseIdentifier = @"ThoughtCell";
    self.thoughtsFetchedResultsControllerDataSource.delegate = self;
}

- (NSFetchedResultsController *)thoughtsFetchedResultsController {
    
    if (_thoughtsFetchedResultsController != nil) {
        return _thoughtsFetchedResultsController;
    }
    NSManagedObjectContext *context = _model.context;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:THOUGHT_RECORD_TYPE];
    
    [self initalizeCollectionPickerView]; // make sure this is called
    Collection *collectionSelected;
    if (self.collectionsFetchedResultsController.fetchedObjects.count == 0) {
        collectionSelected = [self createDefaultCollection];
    } else /*there are fetched collections*/ {
        collectionSelected = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:self.pickerView.selectedItem inSection:0]];
    }
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", PARENT_COLLECTION_KEY, OBJECT_ID_KEY, collectionSelected.objectId];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:PLACEMENT_KEY ascending:NO]; // high #'s @ top for adding
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:20];
    
    _thoughtsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return _thoughtsFetchedResultsController;
    
}

- (void)configureCell:(nullable UITableViewCell*)cell withObject:(nullable Thought *)object {
    cell.textLabel.text = object.text;
}

- (void) deleteObject:(Thought *)object {
    [Thought updatePlacementForDeletionOfThought:object inThoughts:self.thoughtsFetchedResultsController.fetchedObjects];
    [_model deleteFromBothCloudKitAndCoreData:object]; // saves context
}

#pragma mark - Collection Fetched Results Controller

- (void) initalizeCollectionFetchedResultsControllerDataSource {
    self.collectionsFetchedResultsControllerDataSource = [[AKPickerViewFRCDataSource alloc] initWithAKPickerView:self.pickerView];
    self.collectionsFetchedResultsControllerDataSource.fetchedResultsController = self.collectionsFetchedResultsController;
}

- (NSFetchedResultsController *)collectionsFetchedResultsController {
    
    if (_collectionsFetchedResultsController != nil) {
        return _collectionsFetchedResultsController;
    }
    NSManagedObjectContext *context = _model.context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:COLLECTION_RECORD_TYPE];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:PLACEMENT_KEY ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:20];
    
    _collectionsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return _collectionsFetchedResultsController;
    
}

#pragma mark - Add

- (IBAction)addThought:(id)sender {
    NSNumber* numThoughtsInCurrentCollection = [NSNumber numberWithInt:self.thoughtsFetchedResultsController.fetchedObjects.count];
    Collection* currentCollection = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:self.pickerView.selectedItem inSection:0]];
    [self presentViewController:[[Updater new] handleThoughtAdditionWithParent:currentCollection placement:numThoughtsInCurrentCollection]animated:YES completion:nil];
}

#pragma mark - Update

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Thought *selectedThought = [self.thoughtsFetchedResultsController objectAtIndexPath:indexPath];
    [self presentViewController:[[Updater new] handleUpdatingThought:selectedThought] animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Reorderer Delegate

-(IBAction)longPressGestureRecognized:(id)sender {
    [self.reorderer longPressGestureRecognized:sender onTableView:self.tableView];
}

-(void)updatePlacementWithSource:(NSIndexPath *)sourceIndexPath destination:(NSIndexPath *)destinationIndexPath {
    
    Thought *objectMoving = [self.thoughtsFetchedResultsController objectAtIndexPath:sourceIndexPath];
    Thought *objectBeingMoved = [self.thoughtsFetchedResultsController objectAtIndexPath:destinationIndexPath];
    
    NSNumber* sourcePlacement = objectMoving.placement;
    NSNumber* destinationPlacement = objectBeingMoved.placement;
    
    objectMoving.placement = destinationPlacement;
    objectBeingMoved.placement = sourcePlacement;
}

#pragma mark - Segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editCollections"]) {
        CollectionsViewController *vc = (CollectionsViewController *) segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - Helper

- (NSArray<id<FunObject>> *) createFakeRecords {
    
    // initial objects
    Collection *collection = [Collection newCollectionInManagedObjectContext:_model.context name:@"Big Collection"];
    
    NSMutableArray<id<FunObject>> *objectsToSave = [NSMutableArray new];
    [objectsToSave addObject:collection];
    
    for (int i = 0; i < 19; i++) {
        Thought *thought = [Thought newThoughtInManagedObjectContext:_model.context collection:nil];
        [objectsToSave addObject:thought];
        
        // make the connection references between the objects
        [collection addThoughtsObject:thought];
        thought.parentCollection = collection;
        
        // complicate the thought
        thought.text = [NSString stringWithFormat:@"Brilliant idea %d", i];
        thought.location = [[CLLocation alloc] initWithLatitude:42.3333 longitude:-71.333];
        thought.extraText = @"some descritpion text";
        thought.tags = @[@"funny", @"love"];
        thought.reminderDate = [NSDate date];
        thought.placement = [NSNumber numberWithInt:19-i];
        
    }
    
    [_model saveCoreDataContext];
    
    return [NSArray arrayWithArray:objectsToSave];
}

- (Collection *) createDefaultCollection {
    Collection* collectionSelected = [Collection newCollectionInManagedObjectContext:_model.context name:@"Light Bulbs"];
    [self.model saveCollections:[NSArray arrayWithObject:collectionSelected] withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:nil];
    [_model saveCoreDataContext];
    [self.collectionsFetchedResultsController performFetch:NULL];
    [self.pickerView reloadData];
    return collectionSelected;
}

- (void) updateThougthsFRCWithCollection: (Collection *) collectionSelected {
    self.thoughtsFetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", PARENT_COLLECTION_KEY, OBJECT_ID_KEY, collectionSelected.objectId];
    [self.thoughtsFetchedResultsController performFetch:NULL];
    [self.tableView reloadData];
}
@end

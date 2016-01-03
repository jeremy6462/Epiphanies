//
//  MainViewController.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

-(void) viewDidLoad {
    _model = [Model sharedInstance];
    
    [self initalizeCollectionPickerView];
    [self initalizeThoughtsFetchedResultsControllerDataSource];
    
    self.tableView.delegate = self;
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

// rename collections by double tapping or tapping and holding on a collection name in picker

- (void) pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item {
    Collection *collectionSelected = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
    self.thoughtsFetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", PARENT_COLLECTION_KEY, OBJECT_ID_KEY, collectionSelected.objectId];
    [self.thoughtsFetchedResultsController performFetch:NULL];
    [self.tableView reloadData];
}

#pragma mark - Thoughts Fetched Results Controller

- (void) initalizeThoughtsFetchedResultsControllerDataSource {
    self.thoughtsFetchedResultsControllerDataSource = [[TableViewFetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];
    self.thoughtsFetchedResultsControllerDataSource.fetchedResultsController = self.thoughtsFetchedResultsController;
    self.thoughtsFetchedResultsControllerDataSource.reuseIdentifier = @"Cell";
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
        collectionSelected = [Collection newCollectionInManagedObjectContext:_model.context name:@"Light Bulbs"];
        [self.model saveCollections:[NSArray arrayWithObject:collectionSelected] withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:nil];
        [_model saveCoreDataContext];
        [self.collectionsFetchedResultsController performFetch:NULL];
        [self.pickerView reloadData];
    } else /*there are fetched collections*/ {
        collectionSelected = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:self.pickerView.selectedItem inSection:0]];
    }
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", PARENT_COLLECTION_KEY, OBJECT_ID_KEY, collectionSelected.objectId];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:TEXT_KEY ascending:YES];
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
    NSLog(@"Delete Object");
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



# pragma mark - CRUD

- (IBAction)addThought:(id)sender {
    // handle saving the context and deleting the note if X is pressed
    Collection* currentCollection = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:self.pickerView.selectedItem inSection:0]];
    Thought *newThought = [Thought newThoughtInManagedObjectContext:_model.context collection:currentCollection];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"New Idea"
                                          message:@"Enter your new idea here"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = newThought.text;
     }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *textFromUser = ((UITextField *)alertController.textFields.firstObject).text;
        if (textFromUser) {
            newThought.text = textFromUser;
            [_model saveCoreDataContext];
            [_model saveThoughts:[NSArray arrayWithObject:newThought] withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:nil];
        } else {
            [_model deleteObjectFromCoreData:newThought];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [_model deleteObjectFromCoreData:newThought];
    }];
    
    [alertController addAction:ok];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




# pragma mark - Bulk Update
- (void) updateCollectionPicker {
    [self.collectionsFetchedResultsController performFetch:nil];
    [self.pickerView reloadData];
}









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
        
    }
    
    return [NSArray arrayWithArray:objectsToSave];
}

@end

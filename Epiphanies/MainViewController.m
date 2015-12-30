//
//  MainViewController.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

//@synthesize fetchedResultsController = _fetchedResultsController;

-(void) viewDidLoad {
    _model = [Model sharedInstance];
    
    [self initalizeCollectionPickerView];
    [self initalizeThoughtsFetchedResultsControllerDataSource];
    
    self.tableView.delegate = self;
}

#pragma mark - Picker View

- (void) initalizeCollectionPickerView {
    self.pickerView.delegate = self;
    [self initalizeCollectionFetchedResultsControllerDataSource];
    self.pickerView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.pickerView.highlightedFont = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.pickerView.textColor = [UIColor grayColor];
    self.pickerView.highlightedTextColor = [UIColor blackColor];
    self.pickerView.interitemSpacing = 10;
    self.pickerView.fisheyeFactor = 0.0001;
    self.pickerView.pickerViewStyle = AKPickerViewStyle3D;
    [self.pickerView reloadData];
}

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
    
    /*
     Could use for searching for children of the current Collection:
     - thought.parent.objectId - predicateWithFormat:@"%@.%@ == %@", PARENT_COLLECTION_KEY, OBJECT_ID_KEY, collectionSelected.objectId];
     - get rid of thoughtFRC and just use the selected collection's list of thoughts (cons: doesn't update w/ new info)
     - predicateW/Block taking each thought and checking if it's contained in the parent's thoughts
     - LIKE or IN keywords
     */
    Collection *collectionSelected = [self.collectionsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:self.pickerView.selectedItem inSection:0]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K.%K == %@", PARENT_COLLECTION_KEY, OBJECT_ID_KEY, collectionSelected.objectId];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:TEXT_KEY ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:20]; // TODO - change in production
    
    _thoughtsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return _thoughtsFetchedResultsController;
    
}

- (void)configureCell:(nullable UITableViewCell*)cell withObject:(nullable Thought *)object {
    cell.textLabel.text = object.text;
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
    [fetchRequest setFetchBatchSize:20]; // TODO - change in production
    
    _collectionsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return _collectionsFetchedResultsController;
    
}


//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
//    [_thoughtsTableView beginUpdates];
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    
//    UITableView *tableView = _thoughtsTableView;
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [_thoughtsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [_thoughtsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        default:
//            break;
//    }
//}
//
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
//    [_thoughtsTableView endUpdates];
//}

// Adding records code...



- (IBAction)delete:(id)sender {
    NSArray *collections = [Fetcher fetchRecordsFromCoreDataContext:_model.context type:COLLECTION_RECORD_TYPE predicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"] sortDescriptiors:nil];
    
    [_model deleteFromBothCloudKitAndCoreData:collections[0]];
}

- (IBAction)load:(id)sender {
    
    [_model reloadWithCompletion:^(NSArray<Collection *> *populatedCollections, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        } else {
            [self.model saveCoreDataContext];
            for (Collection *collection in populatedCollections) {
                NSLog(@"%@", collection.name);
                NSLog(@"%@", collection.thoughts.anyObject.text);
            }
        }
    }];
    
}

- (IBAction)save:(id)sender {
    
    NSArray *objects = [self createFakeRecords];
    
    [_model saveObjects:objects withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError) {
        if (operationError) {
            NSLog(@"error saving: %@", operationError.description);
        }
    }];
    
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

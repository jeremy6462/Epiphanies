//
//  MainViewController.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 9/14/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize fetchedResultsController = _fetchedResultsController;

-(void) viewDidLoad {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

/*!
 @abstract set up the fetchedResultsController on a property getter overide so that when utilized, it is assuredly non-nil
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _model = [[Model alloc] init];
    
    NSManagedObjectContext *context = _model.context;
    
    // fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:THOUGHT_RECORD_TYPE];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NAME_KEY ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Thought *object = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.text;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_thoughtsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Fetched Controller Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_thoughtsTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = _thoughtsTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_thoughtsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_thoughtsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [_thoughtsTableView endUpdates];
}

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
    Collection *collection = [Collection newCollectionInManagedObjectContext:_model.context name:@"testCollection"];
    Thought *thought = [Thought newThoughtInManagedObjectContext:_model.context collection:nil];
    Photo *photo = [Photo newPhotoInManagedObjectContext:_model.context image:[UIImage imageNamed:@"Bulb Icon"] parentThought:nil];
    
    // make the connection references between the objects
    [collection addThoughtsObject:thought];
    thought.parentCollection = collection;
    [thought addPhotosObject:photo];
    photo.parentThought = thought;
    
    // complicate the thought
    thought.text = @"Brilliant idea";
    thought.location = [[CLLocation alloc] initWithLatitude:42.3333 longitude:-71.333];
    thought.extraText = @"some descritpion text";
    thought.tags = @[@"funny", @"love"];
    thought.reminderDate = [NSDate date];
    
    return [NSArray arrayWithObjects:collection, thought, photo, nil];
}




@end

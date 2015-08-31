//
//  ViewController.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/22/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _model = [[Model alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

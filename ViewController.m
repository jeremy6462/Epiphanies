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

- (IBAction)load:(id)sender {
    [_model reloadWithCompletion:^(NSArray<Collection *> *populatedCollections, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        } else {
            NSLog(@"%@", populatedCollections);
        }
    }];
}

- (IBAction)save:(id)sender {
    [_model saveObjectsToCloudKit:[self createFakeRecords] withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *operationError) {
        if (operationError) {
           NSLog(@"error saving: %@", operationError.description); 
        }
    }];
}

- (NSArray<id<FunObject>> *) createFakeRecords {
    
    // initial objects
    Collection *collection = [[Collection alloc] initWithName:@"testCollection"];
    Thought *thought = [[Thought alloc] init];
    Photo *photo = [[Photo alloc] initWithImage:[UIImage imageNamed:@"Bulb Icon"]];
    
    // make the connection references between the objects
    collection.thoughts  = [NSArray arrayWithObject:thought];
    thought.parentCollection = collection;
    thought.photos = [NSArray arrayWithObject:photo];
    photo.parentThought = thought;
    
    // complicate the thought
    thought.text = @"Brilliant idea";
    thought.location = [[CLLocation alloc] initWithLatitude:42.3333 longitude:-71.333];
    thought.webURL = @"http://www.jerms.work";
    thought.emailURL = @"jkjak6@gmail.com";
    thought.telURL = @"5087983282";
    thought.tags = @[@"funny", @"love"];
    
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

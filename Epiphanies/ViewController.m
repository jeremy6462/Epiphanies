//
//  ViewController.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 7/23/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _container = [CKContainer defaultContainer];
    _database = [_container publicCloudDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)save:(id)sender {
    
//    // create a collection record to save the collection information to
//    CKRecord *collectionRecord = [[CKRecord alloc] initWithRecordType:@"Collection"];
//    
//    // create a collection object to simulate the state of affairs
//    Collection *lyricCollection = [[Collection alloc] init];
//    lyricCollection.name = @"Lyric Ideas";
//    lyricCollection.recordId = [collectionRecord recordID];
//    
//    // add the releveant information to the record
//    [collectionRecord setObject:lyricCollection.name forKey:@"name"];
//    
//    // save the record to the database
//    [_database saveRecord:collectionRecord completionHandler:^(CKRecord *record, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Collection Record name saved: %@", record[@"name"]);
//        }
//    }];
//    
//    
//    // create a thought record to store attributes about a thought
//    CKRecord *thoughtRecord =[[CKRecord alloc] initWithRecordType:@"Thought"];
//    
//    // create a thought object that represents some saved thought
//    Thought *thought = [[Thought alloc] init];
//    thought.text = @"These is the dawning of the rest of our lives";
//    thought.location = [[CLLocation alloc] initWithLatitude:47.2342235346345342 longitude:-15.23524634745];
//    thought.images = [NSArray arrayWithObject:[UIImage imageNamed:@"Bulb Icon"]];
//    thought.recordId = [thoughtRecord recordID];
//    
//    // set the relevent information for that thought
//    [thoughtRecord setObject:thought.text forKey:@"text"];
//    [thoughtRecord setObject:thought.location forKey:@"location"];
//    [thoughtRecord setObject:thought.images forKey:@"images"];
//    
//    // set up a reference to the parent object's collection record
//    CKReference *parent = [[CKReference alloc] initWithRecord:collectionRecord action:CKReferenceActionDeleteSelf];
//    [thoughtRecord setObject:parent forKey:@"parent"];
//    
//    // save the record to the cloud
//    [_database saveRecord:thoughtRecord completionHandler:^(CKRecord *record, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Thought Record name saved: %@", record[@"text"]);
//        }
//    }];
}

- (IBAction)fetch:(id)sender {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == 'Lyric Ideas'"];
    CKQuery *queryAllCollections = [[CKQuery alloc] initWithRecordType:@"Collection" predicate:predicate];
    [_database performQuery:queryAllCollections inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            CKRecord *record = results[0];
            NSLog(@"Collection Record name fetched: %@", record[@"name"]);
        }
    }];

}




@end






















//    Thought *thought1 = [[Thought alloc] init];
//    thought1.text = @"Some people been known to do it all their life";
//    Thought *thought2 = [[Thought alloc] init];
//    thought2.location = [[CLLocation alloc] initWithLatitude:47.25153124 longitude:-15.23563467];

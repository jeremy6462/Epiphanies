//
//  AKPickerViewFRCDataSource.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 12/29/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "AKPickerViewFRCDataSource.h"

@implementation AKPickerViewFRCDataSource

- (id)initWithAKPickerView:(AKPickerView *)pickerView;
{
    self = [super init];
    if (self) {
        self.pickerView = pickerView;
        self.pickerView.dataSource = self;
    }
    return self;
}

- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
}

- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView {
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[0];
    return section.numberOfObjects;
}

- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item {
    Collection *collection = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
    return collection.name;
}


@end

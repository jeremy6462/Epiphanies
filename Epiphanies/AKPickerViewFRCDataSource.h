//
//  AKPickerViewFRCDataSource.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 12/29/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@import UIKit;
#import "AKPickerView.h"

@interface AKPickerViewFRCDataSource : NSObject <AKPickerViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) AKPickerView *pickerView;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

- (id)initWithAKPickerView:(AKPickerView *)pickerView;

@end

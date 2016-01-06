//
//  Reorderer.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/6/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Model.h"

@protocol ReordererDelegate

-(void) updatePlacementWithSource: (NSIndexPath *) sourceIndexPath destination: (NSIndexPath *) destinationIndexPath;

@end

@interface Reorderer : NSObject

@property (weak, nonatomic) id<ReordererDelegate> delegate;

- (IBAction)longPressGestureRecognized:(id)sender onTableView: (UITableView *) tableView ;

@end

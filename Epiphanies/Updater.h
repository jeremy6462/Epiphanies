//
//  Updater.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/12/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface Updater : NSObject

// REFACTOR - Change to subclass for thought and subclass for collections

- (UIAlertController *) handleCollectionAdditionWithPlacement:(NSNumber *)placement;
- (UIAlertController *) handleUpdatingCollection: (Collection *) collection;

- (UIAlertController *) handleThoughtAdditionWithParent:(Collection *)parent placement:(NSNumber *)placement;
- (UIAlertController *) handleUpdatingThought: (Thought *) thought;

@end

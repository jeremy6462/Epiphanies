//
//  Orderer.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/8/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Orderable.h"

@interface Orderer : NSObject

/*!
 @abstract changes the value of the placement property for each object in orderedObjects to match thier relative position in the orderedObjects array
 */
+(nonnull NSArray<id<Orderable>> *)correctPlacementBasedOnOrderInArray:(nonnull NSArray<id<Orderable>> *) orderedObjects;

@end

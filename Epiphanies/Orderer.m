//
//  Orderer.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/8/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "Orderer.h"

@implementation Orderer

+(nonnull NSArray<id<Orderable>> *)orderObjectsBasedOnPlacementInArray:(nonnull NSArray<id<Orderable>> *) orderedObjects {
    
    // fancy algorithm
    for (int i = 0; i < [orderedObjects count]; i++) {
        id<Orderable> object = orderedObjects[i];
        object.placement = [NSNumber numberWithInt:i];
    }
    
    return orderedObjects;
}

@end

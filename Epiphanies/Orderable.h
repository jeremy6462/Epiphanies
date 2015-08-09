//
//  Orderable.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/8/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @abstract based on a placement property, relative order is assigned to an object
 @discussion implementing this class requires a placement property and the order of that placement property can be set at anytime. In the Orderer class, pass an array of id<Orderable> objects to the method orderObjectsBasedOnPlacementInArray: and each object's placement value will be set according to their relative order in the passed Array (let's hope this works with Pass-by-Value so that in the end the objects have their placements set correctly)
 */

@protocol Orderable <NSObject>

/*Save on Database*/    @property (nonnull, nonatomic, strong) NSNumber *placement;

@end

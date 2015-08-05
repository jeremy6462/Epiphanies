//
//  Child.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/4/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Child <NSObject>

/*!
 @abstract removes a child from it's parent's array of children
 */
-(void) removeFromParent;

@end

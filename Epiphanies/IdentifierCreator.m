//
//  IdentifierCreator.m
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/16/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "IdentifierCreator.h"

@implementation IdentifierCreator

// TODO - use different Id system
+ (NSString *) createId {
    NSArray *characters = [NSArray arrayWithObjects:
                                   @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n",
                                   @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    NSMutableString *identifier = [[NSMutableString alloc] init];
    for (int i = 0; i < 7; i++) {
        int index = arc4random_uniform(26);
        [identifier appendString:characters[index]];
    }
    return identifier;

}

@end

//
//  NSString+NSString_AddLinkPrefix.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/6/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import "NSString+NSString_AddLinkPrefix.h"

@implementation NSString (NSString_AddLinkPrefix)

-(NSString *) addPrefix:(Prefix)prefix {
    switch (prefix) {
        case Web:
            return [NSString stringWithFormat:@"%@-%@", WEB, self];
            break;
        case Tel:
            return [NSString stringWithFormat:@"%@-%@", TEL, self];
            break;
        case Email:
            return [NSString stringWithFormat:@"%@-%@", EMAIL, self];
        default:
            return self;
            break;
    }
}

-(NSString *) deprefixLink {
    
    // loop through all of the characters in linkWithPrefix searching for '-'
    for (int i = 0; i < [self length]; i++) {
        
        if ([self characterAtIndex:i] == '-') {
            return [self substringFromIndex:i];
        }
    }
    return self;

}

-(Prefix)URLTypeForPrefixedLink {
    
    // loop through all of the characters in linkWithPrefix searching for '-'
    for (int i = 0; i < [self length]; i++) {
        
        if ([self characterAtIndex:i] == '-') {
            
            // The word to the left of the '-' is the prefix
            NSString *prefix = [self substringToIndex:i];
            
            // Match the prefix with the Prefix enum
            if ([prefix isEqualToString:WEB]) {
                return Web;
            } else if ([prefix isEqualToString:TEL]) {
                return Tel;
            } else if ([prefix isEqualToString:EMAIL]) {
                return Email;
            } else {
                return None;
            }
        }
    }
    return None;
}

@end

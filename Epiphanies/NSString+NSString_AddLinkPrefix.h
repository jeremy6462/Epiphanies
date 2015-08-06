//
//  NSString+NSString_AddLinkPrefix.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/6/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEB @"web"
#define TEL @"tel"
#define EMAIL @"email"

typedef NS_ENUM(NSInteger, Prefix) {
    Web,
    Tel,
    Email,
    None
};

@interface NSString (NSString_AddLinkPrefix)

/*!
 @param prefix one of the supported URL types. Based on this value a certain String constant will be added onto the beginning of the link. If no prefix is passed, just the link is returned
 @param self that will be utilized
 @return a NSString that contains the prefix, a dash delimiter, and the link.
 */
-(nonnull NSString *)addPrefix:(Prefix) prefix;

/*!
 @param self a link that has been prefixed by addPrefix: forLink: ("prefix-link")
 @return a prefix entry that details the type of link that was profided
 */
-(Prefix) URLTypeForPrefixedLink;

/*!
 @param self a link that has been prefixed by addPrefix: forLink: ("prefix-link")
 @return the original link without a prefix appended. If no dash was found, returns linkWithPrefix
 */
-(nullable NSString *)deprefixLink;

@end

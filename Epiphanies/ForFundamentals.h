//
//  ForFundamentals.h
//  EpiphaniesScratch
//
//  Created by Jeremy Kelleher on 7/16/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#ifndef EpiphaniesScratch_ForFundamentals_h
#define EpiphaniesScratch_ForFundamentals_h

// Record types in CloudKit database
#define COLLECTION_RECORD_TYPE @"Collection"
#define THOUGHT_RECORD_TYPE @"Thought"
#define PHOTO_RECORD_TYPE @"Photo"

// Key's in the CloudKit database
#define OBJECT_ID_KEY @"objectId"
#define RECORD_ID_KEY @"recordId"
#define NAME_KEY @"name"
#define TEXT_KEY @"text"
#define PARENT_COLLECTION_KEY @"parentCollection"
#define LOCATION_KEY @"location"
#define PLACEMENT_KEY @"placement"
#define PARENT_THOUGHT_KEY @"parentThought"
#define IMAGE_KEY @"image"

#import "IdentifierCreator.h"
#import "FunObject.h"
#import "Child.h"
#import "NSString+NSString_AddLinkPrefix.h"

#endif

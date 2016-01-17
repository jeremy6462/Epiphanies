//
//  StringConstants.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/30/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#ifndef StringConstants_h
#define StringConstants_h

// Record types in CloudKit database
#define COLLECTION_RECORD_TYPE @"Collection"
#define THOUGHT_RECORD_TYPE @"Thought"
#define PHOTO_RECORD_TYPE @"Photo"

// Key's in the CloudKit database
#define TYPE_KEY @"type"
#define OBJECT_ID_KEY @"objectId"
#define RECORD_ID_KEY @"recordId"
#define RECORD_DATA_KEY @"recordData"
#define RECORD_NAME_KEY @"recordName"
#define PLACEMENT_KEY @"placement"
#define NAME_KEY @"name"
#define THOUGHTS_KEY @"thoughts"

#define TEXT_KEY @"text"
#define LOCATION_KEY @"location"
#define PHOTOS_KEY @"photos"
#define EXTRA_TEXT_KEY @"extraText"
#define TAGS_KEY @"tags"
#define CREATION_DATE_KEY @"creationDate"
#define REMINDER_DATE_KEY @"reminderDate"
#define PARENT_COLLECTION_KEY @"parentCollection"

#define PARENT_THOUGHT_KEY @"parentThought"
#define IMAGE_KEY @"image"

// Notifications
#define EP_NewCollectionCellReadyForTextFieldEditing @"EPNewCollectionCellReadyForTextFieldEditing"

#endif /* StringConstants_h */

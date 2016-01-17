//
//  RecordArchiveHandler.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/17/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"

@interface RecordArchiveHandler : NSObject

-(NSData *) archive: (CKRecord *)record;
-(CKRecord *) unarchive: (NSData *) archivedData;

@end

//
//  FunObject.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 8/2/15.
//  Copyright © 2015 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Frameworks.h"

@protocol FunObject <NSObject>

@property (nullable, nonatomic, strong) CKRecordID *recordId;

-(CKRecord *) asRecord;

-(CKRecord *) asRecordWithChanges:(NSDictionary *)dictionaryOfChanges;

@end

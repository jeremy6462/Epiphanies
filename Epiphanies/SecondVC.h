//
//  SecondVC.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 7/26/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CloudKit;
#import "Thought.h"
#import "Collection.h"

@interface SecondVC : UIViewController

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *database;

@property (nonatomic, strong) CKRecordZoneID *zoneId;

@end

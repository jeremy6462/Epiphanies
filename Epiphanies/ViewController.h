//
//  ViewController.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 7/23/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

@import CloudKit;
@import MapKit;

#import <UIKit/UIKit.h>

#import "AppDelegate.h"


@interface ViewController : UIViewController

@property (nonatomic, strong) CKContainer *container;
@property (nonatomic, strong) CKDatabase *database;

@end


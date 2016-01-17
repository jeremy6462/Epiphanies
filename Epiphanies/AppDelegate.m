//
//  AppDelegate.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 7/23/15.
//  Copyright (c) 2015 JKProductions. All rights reserved.
//

#import "AppDelegate.h"
#import "Frameworks.h"
#import "ForFundamentals.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Notifications

-(void)application:(nonnull UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotifications device token: %@", deviceToken.description);
}

-(void)application:(nonnull UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    NSLog(@"Error registering for Remote Notifications: %@", error.description); // simulator can't handle remote notificaitons
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    [self handleCloudKitNotification:cloudKitNotification];
    // TODO - call the completion handler??
}

- (void) handleCloudKitNotification: (CKNotification *) cloudKitNotification {
    
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        
        // first, fetch any possibly missed notifications. Not processing the cloudKitNotification just yet b/c want to fetch for possibly missed notifications first.
        CKFetchNotificationChangesOperation *operationFetchMissing = [CKFetchNotificationChangesOperation new];
        
        operationFetchMissing.notificationChangedBlock = ^void(CKNotification *notification) {
            if (notification.notificationType == CKNotificationTypeQuery) {
                CKQueryNotification *ckQueryNotification = (CKQueryNotification *)cloudKitNotification;
                CKRecordID *fetchedRecordId = [ckQueryNotification recordID];
                if (ckQueryNotification.recordFields) {
                    [[Model sharedInstance] fetchCKRecordAndUpdateCoreData:fetchedRecordId];
                }

            }
        };
        
        // handle the operation's completion or early return based on a serverChangeToken - what??
        operationFetchMissing.fetchNotificationChangesCompletionBlock =^void(CKServerChangeToken *serverChangeToken, NSError *operationError) {
            if (operationError) {
                NSLog(@"error fetching notifications ERROR HANDLING HERE: %@", operationError);
            } else {
                // TODO - figure out a way to mark notifications as read
                CKMarkNotificationsReadOperation *operationMarkRead = [[CKMarkNotificationsReadOperation alloc] initWithNotificationIDsToMarkRead:@[]];
                operationMarkRead.qualityOfService = NSOperationQualityOfServiceBackground;
                operationMarkRead.markNotificationsReadCompletionBlock = ^void(NSArray <CKNotificationID *> * _Nullable notificationIDsMarkedRead, NSError * _Nullable markOperationError) {
                    NSLog(@"error marking notifciations as read ERROR HANDLING HERE: %@", markOperationError);
                };
            }
        };
        
        operationFetchMissing.qualityOfService = NSOperationQualityOfServiceBackground;
        [[Model sharedInstance] executeContainerOperation:operationFetchMissing];
        
        // process the fetched record for the currently just accepted notificaton - occuring afer the operation setup so the fetch of extra notifications could happen in the background
        CKQueryNotification *ckQueryNotification = (CKQueryNotification *)cloudKitNotification;
        CKRecordID *fetchedRecordId = [ckQueryNotification recordID];
        if (ckQueryNotification.recordFields) {
            [[Model sharedInstance] fetchCKRecordAndUpdateCoreData:fetchedRecordId];
        }
    }
}

#pragma mark - Application Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Register for silent notifications
    // TODO - handle reminder notifications as local notifications?
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Model

-(Model *) model {
    return [Model sharedInstance];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.JKProductions.Epiphanies" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Epiphanies" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Epiphanies.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // TODO - Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end

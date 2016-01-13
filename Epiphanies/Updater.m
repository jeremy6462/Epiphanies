//
//  Updater.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/12/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import "Updater.h"

@implementation Updater

{
    BOOL dealingWithCollections;
    NSString* titleText;
    NSString* messageText;
    NSString* confirmButtonText;
    NSString* cancelButtonText;
}

- (UIAlertController *) handleCollectionAdditionWithPlacement:(NSNumber *)placement {
    dealingWithCollections = YES;
    [self setViewTextForAddingCollection];
    Collection *collection = [Collection newCollectionInManagedObjectContext:[Model sharedInstance].context placement:placement];
    return [self presentUIForAddingObject:collection];
}

- (UIAlertController *) handleUpdatingCollection: (Collection *) collection {
    dealingWithCollections = YES;
    [self setViewTextForUpdatingCollection];
    return [self presentUIForUpdatingObject:collection];
}

- (UIAlertController *) handleThoughtAdditionWithParent:(Collection *)parent placement:(NSNumber *)placement {
    dealingWithCollections = NO;
    [self setViewTextForAddingThought];
    Thought *thought = [Thought newThoughtInManagedObjectContext:[Model sharedInstance].context collection:parent];
    thought.placement = placement;
    return [self presentUIForAddingObject:thought];
}

- (UIAlertController *) handleUpdatingThought: (Thought *) thought {
    dealingWithCollections = NO;
    [self setViewTextForUpdatingThought];
    return [self presentUIForUpdatingObject:thought];
}

- (UIAlertController *) presentUIForAddingObject: (id<FunObject>) object {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleText message:messageText preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:confirmButtonText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *textFromUser = ((UITextField *)alertController.textFields.firstObject).text;
        if (![textFromUser isEqualToString:@""]) {
            if (dealingWithCollections) {
                ((Collection *) object).name = textFromUser;
            } else {
                ((Thought *) object).text = textFromUser;
            }
            [[Model sharedInstance] saveCoreDataContext];
            [[Model sharedInstance] saveObjects:[NSArray arrayWithObject:object] withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:nil];
        } else {
            [[Model sharedInstance] deleteFromBothCloudKitAndCoreData:object];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelButtonText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[Model sharedInstance] deleteFromBothCloudKitAndCoreData:object];
    }];
    
    [alertController addAction:ok];
    [alertController addAction:cancel];
    
    return alertController;
}

- (UIAlertController *) presentUIForUpdatingObject: (id<FunObject>) object {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleText message:messageText preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (dealingWithCollections) {
            textField.placeholder = ((Collection *) object).name;
        } else {
           textField.placeholder = ((Thought *) object).text;
        }

    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:confirmButtonText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *textFromUser = ((UITextField *)alertController.textFields.firstObject).text;
        if (![textFromUser isEqualToString:@""]) {
            if (dealingWithCollections) {
                ((Collection *) object).name = textFromUser;
            } else {
                ((Thought *) object).text = textFromUser;
            }
            [[Model sharedInstance] saveCoreDataContext];
            [[Model sharedInstance] saveObjects:[NSArray arrayWithObject:object] withPerRecordProgressBlock:nil withPerRecordCompletionBlock:nil withCompletionBlock:nil];
        } else {
            // present view controller saying collections must have a name
            
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelButtonText style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:ok];
    [alertController addAction:cancel];
    
    return alertController;
}


# pragma mark - Set Text for Appropriate Context

- (void) setViewTextForAddingThought {
    [self setViewText:@"New Idea" message:@"Enter text for the idea here" confirmButton:@"Save" cancelButton:@"Cancel"];
}

- (void) setViewTextForUpdatingThought {
    [self setViewText:@"Update Idea" message:@"Enter text for the idea here" confirmButton:@"Update" cancelButton:@"Cancel"];
}

- (void) setViewTextForAddingCollection {
    [self setViewText:@"Add Collection" message:@"Enter a name for the Collection here" confirmButton:@"Save" cancelButton:@"Cancel"];
}

- (void) setViewTextForUpdatingCollection {
    [self setViewText:@"Update Collection" message:@"Enter a name for the Collection here" confirmButton:@"Update" cancelButton:@"Cancel"];
}


- (void) setViewText:(NSString *) title message: (NSString *) message confirmButton: (NSString *) confirmButton cancelButton: (NSString *) cancelButton {
    titleText = title;
    messageText = message;
    confirmButtonText = confirmButton;
    cancelButtonText = cancelButton;
}

@end

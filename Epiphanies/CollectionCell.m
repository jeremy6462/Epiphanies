//
//  CollectionCell.m
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/10/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import "CollectionCell.h"

@implementation CollectionCell

- (void) awakeFromNib {
    self.textField.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"didEndEditing");
    // should save the text to a new collection object
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"shouldReturn");
    return YES;
}



@end

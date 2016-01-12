//
//  CollectionCell.h
//  Epiphanies
//
//  Created by Jeremy Kelleher on 1/10/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface CollectionCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) Collection *collection;

@end

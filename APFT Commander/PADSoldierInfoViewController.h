//
//  PADSoldierInfoViewController.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/4/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Soldier.h"

@interface PADSoldierInfoViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) Soldier *soldier;
@property (nonatomic, retain) NSArray *pickerDataSource;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;


@end

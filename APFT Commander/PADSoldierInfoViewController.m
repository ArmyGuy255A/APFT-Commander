//
//  PADSoldierInfoViewController.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/4/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import "PADSoldierInfoViewController.h"
#import "AppDelegate.h"
#import "PADActionClass.h"
#import "PADEventInfoViewController.h"

@implementation PADSoldierInfoViewController


-(void)viewDidLoad {
    //intialize the picker
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self loadPicker];
    
    UIBarButtonItem *addEventButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    [self.navigationItem setRightBarButtonItem:addEventButton];
    
    //Make all the text fields this controller's delegate
    NSEnumerator *e = [self.view.subviews objectEnumerator];
    UITextField *textField;
    while (textField = [e nextObject]) {
        if ([textField isKindOfClass:[UITextField class]]) {
            textField.delegate = self;
        }
    }
    
    self.lastNameTextField.text = self.soldier.lastName;
    self.firstNameTextField.text = self.soldier.firstName;
    
    //set the age. Remember, age starts at 12. So picker object 0 = 12. Subtract 12 from the age to get the right age to appear.
    if ([self.soldier.age intValue] < 12) {
        self.soldier.age = [NSNumber numberWithInt:12];
    }
    [self.pickerView selectRow:([self.soldier.age intValue] - 12) inComponent:2 animated:NO];
    
    
    //set the sex
    bool sex = 0;
    if ([self.soldier.sex isEqualToString:@"Female"]) {
        sex = 1;
    }
    [self.pickerView selectRow:sex inComponent:1 animated:NO];
    
    
    //set the rank
    NSArray *ranks = [self.pickerDataSource objectAtIndex:0];
    NSString *rank;
    for (int x = 0; x < ranks.count; x++) {
        rank = (NSString *)[ranks objectAtIndex:x];
        if ([rank isEqualToString:self.soldier.rank ]) {
            [self.pickerView selectRow:x inComponent:0 animated:NO];
        }
    }
    
    
}

-(void) viewDidDisappear:(BOOL)animated {
    if (self.soldier.managedObjectContext.hasChanges) {
        [self.soldier.managedObjectContext save:nil];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    //If the soldier's last name and first name are empty - delete the soldier.
    if ((self.soldier.lastName.length == 0) && (self.soldier.firstName.length == 0)) {
        [self.soldier.managedObjectContext deleteObject:self.soldier];
    }
}

#pragma mark - Text Field Delegate
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    switch (textField.tag) {
        case 0:
            self.soldier.lastName = textField.text;
            break;
        case 1:
            self.soldier.firstName = textField.text;
            break;
        default:
            break;
    }
    //Save
    if (self.soldier.managedObjectContext.hasChanges) {
        [self.soldier.managedObjectContext save:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //Input Validation on the text fields
    
    // do not allow the first character to be space | do not allow more than one space
    if ([string isEqualToString:@" "]) {
        if (!textField.text.length)
            return NO;
        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            return NO;
    }
    
    // allow backspace
    if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
        return YES;
    }
    
    // in case you need to limit the max number of characters
    if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 15) {
        return NO;
    }
    
    // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
    //NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ. "];
    if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
        return NO;
    }
    
    //Otherwise.. go ahead and return
    return YES;
}

#pragma mark - Picker View Delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //Return each rank in the array of dictionary
    return [[self.pickerDataSource objectAtIndex:component] objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Update the data model
    switch (component) {
        case 0:
            //Rank
            self.soldier.rank = [[self.pickerDataSource objectAtIndex:0] objectAtIndex:row];
            break;
        case 1:
            //Sex
            row == 0 ? (self.soldier.sex = @"Male") : (self.soldier.sex = @"Female");
            break;
        case 2:
            //Age (remember, add 12 because the selected index accounts for a minimum age of 12
            self.soldier.age = [NSNumber numberWithInteger:row + 12];
            break;
        default:
            break;
    }
    //Save
    if (self.soldier.managedObjectContext.hasChanges) {
        [self.soldier.managedObjectContext save:nil];
    }
}

#pragma mark - Picker View Data Source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.pickerDataSource count];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.pickerDataSource objectAtIndex:component] count];
    
}

#pragma mark - View Controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"NewEventSegue"]) {
        PADEventInfoViewController *viewController = segue.destinationViewController;
        //Create a new event
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSEntityDescription *soldierEntity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Event"];
        Event *event = [NSEntityDescription insertNewObjectForEntityForName:[soldierEntity name] inManagedObjectContext:delegate.managedObjectContext];
        [self.soldier addEventsObject:event];
        [event setDate:[NSDate date]];
        viewController.event = event;
    }
}

-(void)addEvent {
    [self performSegueWithIdentifier:@"NewEventSegue" sender:nil];
}

-(void)loadPicker {
    NSArray *arrayRanks = [[NSArray alloc] initWithObjects:
                           @"PV1",
                           @"PV2",
                           @"PFC",
                           @"SPC",
                           @"CPL",
                           @"SGT",
                           @"SSG",
                           @"SFC",
                           @"MSG",
                           @"1SG",
                           @"SGM",
                           @"CSM",
                           @"WO1",
                           @"CW2",
                           @"CW3",
                           @"CW4",
                           @"CW5",
                           @"2LT",
                           @"1LT",
                           @"CPT",
                           @"MAJ",
                           @"LTC",
                           @"COL",
                           @"BG",
                           @"MG",
                           @"LTG",
                           @"GEN",
                           nil];
    
    NSArray *arraySexes = [[NSArray alloc] initWithObjects:
                           @"Male",
                           @"Female",
                           nil];
    
    //Use ages 12 to 70.
    NSMutableArray *arrayAges = [[NSMutableArray alloc] init];
    for (int x = 12; x <= 70; x++) {
        [arrayAges addObject:[PADActionClass cNumToString:[NSNumber numberWithInt:x]]];
    }
    
    self.pickerDataSource = [[NSArray alloc] initWithObjects:
                             arrayRanks,
                             arraySexes,
                             arrayAges,
                             nil];
}



@end

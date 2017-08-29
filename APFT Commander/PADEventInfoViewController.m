//
//  PADEventInfoViewController.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/7/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import "PADEventInfoViewController.h"
#import "PADCalc.h"
#import "PADActionClass.h"
#import "PADEventTableViewController.h"


@implementation PADEventInfoViewController

-(void)viewDidLoad {
    //intialize the picker
    self.title = [NSString stringWithFormat:@"%@, %@ %@",
                  self.event.soldier.lastName,
                  self.event.soldier.firstName,
                  self.event.soldier.rank];
    
    self.eventScorePicker.delegate = self;
    self.eventScorePicker.dataSource = self;
    [self loadPicker];
    
    //Set values for the picker.
    [self updatePicker];
    //Update the picker label locations
    [self updatePickerLabelLocations];
    
    //Update the labels
    [self updateMainLabel];
    [self updateDetailLabel];
    [self updateEventLabel:self.puScoreLabel eventType:kExercisePushup];
    [self updateEventLabel:self.suScoreLabel eventType:kExerciseSitup];
    [self updateEventLabel:self.runScoreLabel eventType:kExerciseRun];
    
    //Set the selected segment.
    [self.segmentedTestControl setSelectedSegmentIndex:[self.event.testType integerValue]];
    
    //Set the date picker
    [self.datePicker setDate:self.event.date];
    //Move the picker down if it's an iPhone 4s 480
    
    if(([UIScreen mainScreen].bounds.size.height) == 480) {
        [self.datePickerConstratint setConstant:-90.0f];
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    if (self.event.managedObjectContext.hasChanges) {
        [self.event.managedObjectContext save:nil];
    }
}

#pragma mark - Segmented Control
- (IBAction)updateDate:(UIDatePicker *)sender {
    self.event.date = sender.date;
}

#pragma mark - Segmented Control
- (IBAction)updateTestType:(UISegmentedControl *)sender {
    //Remember, the segmented control will have 2 indicies. 0 for Diagnostic and 1 for Record. This matches our data model.
    self.event.testType = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
}


#pragma mark - Picker View Delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self.pickerDataSource objectAtIndex:component] objectAtIndex:row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 25.0f;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //update the constraints dynamically
    float size = ([UIScreen mainScreen].bounds.size.width / 5);
    switch (component) {
        case 0:
            return size * .75;
            break;
        case 2:
            return size + 5;
            break;
        case 3:
            return size * .75;
            break;
        default:
            return size;
            break;
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Update the data model
    switch (component) {
        case 0:
            //Pushup
            [self updateEventLabel:self.puScoreLabel eventType:kExercisePushup];
            break;
        case 1:
            //Situp
            [self updateEventLabel:self.suScoreLabel eventType:kExerciseSitup];
            break;
        case 2:
            //Run
            [self updateEventLabel:self.runScoreLabel eventType:kExerciseRun];
            break;
        case 3:
            //Height
            self.event.height = [NSNumber numberWithInteger:row];
            break;
        case 4:
            //Weight
            self.event.weight = [NSNumber numberWithInteger:row];
            break;
        default:
            break;
    }
    
    
    [self updateDetailLabel];
    [self updateMainLabel];
    
    //Save
    if (self.event.managedObjectContext.hasChanges) {
        [self.event.managedObjectContext save:nil];
    }
}

#pragma mark - Picker View Data Source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.pickerDataSource count];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.pickerDataSource objectAtIndex:component] count];
    
}

-(void)loadPicker {
    
    NSMutableArray *arrayRepetitions = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < 300; x++) {
        [arrayRepetitions addObject:[NSString stringWithFormat:@"%i", x]];
    }
    
    NSMutableArray *arrayRacetimes = [[NSMutableArray alloc] init];
    [arrayRacetimes addObject:@"0"];
    int min = 8;
    for (;min < 36; min++) {
        for (int sec = 00; sec < 60; sec++) {
            
            if (sec < 10) {
                [arrayRacetimes addObject:[NSString stringWithFormat:@"%i:0%i", min, sec]];
            } else {
                [arrayRacetimes addObject:[NSString stringWithFormat:@"%i:%i", min, sec]];
            }
        }
    }
    
    
    
    self.pickerDataSource = [[NSArray alloc] initWithObjects:
                             arrayRepetitions,
                             arrayRepetitions,
                             arrayRacetimes,
                             arrayRepetitions,
                             arrayRepetitions,
                             nil];
}

-(void)updatePicker {
    //Update the pushup and situps
    [self.eventScorePicker selectRow:[self.event.pushUp integerValue] inComponent:0 animated:NO];
    [self.eventScorePicker selectRow:[self.event.sitUp integerValue] inComponent:1 animated:NO];
    
    //Update the runtime
    NSMutableString *runTime = [[NSMutableString alloc] initWithString:[PADCalc cNumToString:self.event.run]];
    if (runTime.length > 1) {
        //insert a colon before the last two digits.
        [runTime insertString:@":" atIndex:runTime.length - 2];
    }
    NSArray *runTimes = [self.pickerDataSource objectAtIndex:2];
    [self.eventScorePicker selectRow:[runTimes indexOfObject:runTime] inComponent:2 animated:NO];
    
    //Update the height and weights
    [self.eventScorePicker selectRow:[self.event.height integerValue] inComponent:3 animated:NO];
    [self.eventScorePicker selectRow:[self.event.weight integerValue] inComponent:4 animated:NO];
    
}

-(void)updatePickerLabelLocations {
    //Get the screen bounds and divide by 5. These are the 5 locations for our labels
    float screenSize = [UIScreen mainScreen].bounds.size.width / 5;
    
    //load all the labels in order of precedence: pushup, situp, run, height, weight
    NSArray *constraints = [NSArray arrayWithObjects:self.pushupLabelConstraint, self.situpLabelConstraint, self.runLabelConstraint, self.heightLabelConstraint, self.weightLabelConstraint, nil];
    int x = 2;
    for (NSLayoutConstraint *constraint in constraints) {
        [constraint setConstant:screenSize * x];
        x--;
    }
}

-(void)updateMainLabel {
    self.mainLabel.text = [self.event.finalScore stringValue];
}

-(void)updateDetailLabel {
    //All of our heavy calculations are going on in this method.
    
    NSNumber *pu = [PADCalc getPU:[self.event.pushUp stringValue] soldierAge:self.event.soldier.age soldierSex:self.event.soldier.sex];
    NSNumber *su = [PADCalc getSU:[self.event.sitUp stringValue] soldierAge:self.event.soldier.age soldierSex:self.event.soldier.sex];
    NSNumber *run = [PADCalc getRun:[self.event.run stringValue] soldierAge:self.event.soldier.age soldierSex:self.event.soldier.sex];
    self.event.finalScore = [PADCalc compileScore:run scorePU:pu scoreSU:su soldierSex:self.event.soldier.sex];
    
    
    NSArray *scores = [NSArray arrayWithObjects:pu, su, run, nil];
    bool passed = YES;
    bool extScale = YES;
    
    for (NSNumber *score in scores) {
        if (passed || extScale) {
            if ([score intValue] == 0) {
                //Soldier is Exempt from event. Do not consider
            } else if ([score intValue] < 60) {
                //Soldier failed
                passed = NO;
                extScale = NO;
            } else if ([score intValue] <= 100) {
                //Soldier passed
                passed = YES;
                extScale = NO;
            } else if ([score intValue] > 100) {
                //Soldier is in the extended scale
                passed = YES;
                extScale = YES;
            }
        }
    }
    
    if (!passed) {
        self.detailLabel.text = @"FAIL";
        self.detailLabel.textColor = [UIColor redColor];
    } else if (passed && !extScale){
        self.detailLabel.text = @"PASS";
        self.detailLabel.textColor = [UIColor blackColor];
    } else if (passed && extScale) {
        self.detailLabel.text = @"PASS";
        self.detailLabel.textColor = [UIColor blueColor];
    }
    
    
}

-(void)updateEventLabel:(UILabel *)label eventType:(kExerciseType)type {
    NSMutableString *rawScore = [NSMutableString stringWithString:[[self.pickerDataSource objectAtIndex:type] objectAtIndex:[self.eventScorePicker selectedRowInComponent:type]]];
    [rawScore replaceOccurrencesOfString:@":" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, rawScore.length -1)];
    NSNumber *score;
    
    switch (type) {
        case kExercisePushup:
            score = [PADCalc getPU:rawScore soldierAge:self.event.soldier.age soldierSex:self.event.soldier.sex];
            self.event.pushUp = [PADCalc cStringToNum:rawScore];
            break;
        case kExerciseSitup:
            score = [PADCalc getSU:rawScore soldierAge:self.event.soldier.age soldierSex:self.event.soldier.sex];
            self.event.sitUp = [PADCalc cStringToNum:rawScore];
            break;
        case kExerciseRun:
            score = [PADCalc getRun:rawScore soldierAge:self.event.soldier.age soldierSex:self.event.soldier.sex];
            self.event.run = [PADCalc cStringToNum:rawScore];
            break;
        default:
            break;
    }
    
    label.text = [score stringValue];
    
    
    //Set the color
    if ([score intValue] > 100) {
        label.textColor = [UIColor blueColor];
    } else if ([score intValue] == 0) {
        label.text = @"NA";
        label.textColor = [UIColor blackColor];
    } else if ([score intValue] < 60) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
    
}

@end

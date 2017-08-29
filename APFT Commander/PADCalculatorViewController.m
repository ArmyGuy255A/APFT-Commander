//
//  PADCalculatorViewController.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/14/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import "PADCalculatorViewController.h"

@implementation PADCalculatorViewController

-(void)viewDidLoad {
    //intialize the picker
    self.title = @"Calculator";
    
    self.eventScorePicker.delegate = self;
    self.eventScorePicker.dataSource = self;
    self.age = [NSNumber numberWithInteger:25];
    self.sex = @"Male";
    self.pushupScore = 0;
    self.situpScore = 0;
    self.runScore = 0;
    [self loadPicker];
    
    //Set values for the picker.
    [self.eventScorePicker selectRow:0 inComponent:0 animated:NO];
    [self.eventScorePicker selectRow:0 inComponent:1 animated:NO];
    [self.eventScorePicker selectRow:391 inComponent:2 animated:NO];
    [self.eventScorePicker selectRow:[self.age integerValue]-12 inComponent:3 animated:NO];
    
    //Update the picker label locations
    [self updatePickerLabelLocations];
    
    //Update the labels
    [self updateResultLabels];
    [self updateEventLabel:self.puScoreLabel eventType:kExercisePushup];
    [self updateEventLabel:self.suScoreLabel eventType:kExerciseSitup];
    [self updateEventLabel:self.runScoreLabel eventType:kExerciseRun];
    
    //Set the selected segment.
    [self.genderPicker setSelectedSegmentIndex:1];

}

#pragma mark - Segmented Control
- (IBAction)updateGender:(UISegmentedControl *)sender {
    //Remember, the segmented control will have 2 indicies. 0 for Female and 1 for Male. This matches our data model.
    sender.selectedSegmentIndex == 0 ? (self.sex = @"Female") : (self.sex = @"Male");
    
    //Update all of the scores because a gender change will change everything
    [self updateEventLabel:self.puScoreLabel eventType:kExercisePushup];
    [self updateEventLabel:self.suScoreLabel eventType:kExerciseSitup];
    [self updateEventLabel:self.runScoreLabel eventType:kExerciseRun];
    
    //Finally, update the test results since the segmented control index has changed.
    [self updateResultLabels];
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
    float size = ([UIScreen mainScreen].bounds.size.width / 4.5);
    switch (component) {
        case 0:
            return size;
            break;
        case 1:
            return size;
            break;
        case 2:
            return size;
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
            //Age
            //This will result in a complete recalculation of all the scores.
            self.age = [NSNumber numberWithInteger:row + 12];
            [self updateEventLabel:self.puScoreLabel eventType:kExercisePushup];
            [self updateEventLabel:self.suScoreLabel eventType:kExerciseSitup];
            [self updateEventLabel:self.runScoreLabel eventType:kExerciseRun];
        default:
            break;
    }
    
    [self updateResultLabels];
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
    
    for (int x = 0; x < 300; x++) {
        [arrayRepetitions addObject:[NSString stringWithFormat:@"%i", x]];
    }
    
    //Use ages 12 to 70.
    NSMutableArray *arrayAges = [[NSMutableArray alloc] init];
    for (int x = 12; x <= 70; x++) {
        [arrayAges addObject:[PADActionClass cNumToString:[NSNumber numberWithInt:x]]];
    }
    
    self.pickerDataSource = [[NSArray alloc] initWithObjects:
                             arrayRepetitions,
                             arrayRepetitions,
                             arrayRacetimes,
                             arrayAges,
                             nil];
}


-(void)updatePickerLabelLocations {
    //Get the screen bounds and divide by 5. These are the 4 locations for our labels
    float screenSize = [UIScreen mainScreen].bounds.size.width / 5;
    
    //load all the labels in order of precedence: pushup, situp, run, height, weight
    NSArray *constraints = [NSArray arrayWithObjects:self.pushupLabelConstraint, self.situpLabelConstraint, self.runLabelConstraint, self.ageLabelConstraint, nil];
    float x = 1.5;
    for (NSLayoutConstraint *constraint in constraints) {
        [constraint setConstant:screenSize * x];
        x--;
    }
    

}

-(void)updateResultLabels {
    //All of our heavy calculations are going on in this method.
    
    NSNumber *pu = [PADCalc getPU:[self.pushupScore stringValue] soldierAge:self.age soldierSex:self.sex];
    NSNumber *su = [PADCalc getSU:[self.situpScore stringValue] soldierAge:self.age soldierSex:self.sex];
    NSNumber *run = [PADCalc getRun:[self.runScore stringValue] soldierAge:self.age soldierSex:self.sex];
    self.finalScore = [PADCalc compileScore:run scorePU:pu scoreSU:su soldierSex:self.sex];
    self.mainLabel.text = [self.finalScore stringValue];
    
    
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
            score = [PADCalc getPU:rawScore soldierAge:self.age soldierSex:self.sex];
            self.pushupScore = [PADCalc cStringToNum:rawScore];
            break;
        case kExerciseSitup:
            score = [PADCalc getSU:rawScore soldierAge:self.age soldierSex:self.sex];
            self.situpScore = [PADCalc cStringToNum:rawScore];
            break;
        case kExerciseRun:
            score = [PADCalc getRun:rawScore soldierAge:self.age soldierSex:self.sex];
            self.runScore = [PADCalc cStringToNum:rawScore];
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

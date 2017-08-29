//
//  PADCalculatorViewController.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/14/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PADCalc.h"
#import "PADActionClass.h"

typedef enum {
    kExercisePushup = 0,
    kExerciseSitup = 1,
    kExerciseRun = 2,
} kExerciseType;

@interface PADCalculatorViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) NSArray *pickerDataSource;
@property (nonatomic, retain) NSNumber *pushupScore;
@property (nonatomic, retain) NSNumber *situpScore;
@property (nonatomic, retain) NSNumber *runScore;
@property (nonatomic, retain) NSNumber *finalScore;
@property (nonatomic, retain) NSNumber *age;
@property (nonatomic, retain) NSString *sex;

@property (strong, nonatomic) IBOutlet UISegmentedControl *genderPicker;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *eventScorePicker;
@property (strong, nonatomic) IBOutlet UILabel *puScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *suScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *runScoreLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ageLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *runLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *situpLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pushupLabelConstraint;

@end

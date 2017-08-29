//
//  PADEventInfoViewController.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/7/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Soldier.h"

typedef enum {
    kExercisePushup = 0,
    kExerciseSitup = 1,
    kExerciseRun = 2,
} kExerciseType;

@interface PADEventInfoViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSArray *pickerDataSource;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedTestControl;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;

@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *puScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *suScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *runScoreLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *eventScorePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerConstratint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *weightLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *runLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *situpLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pushupLabelConstraint;



@end

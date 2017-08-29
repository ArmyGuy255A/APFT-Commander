//
//  Event.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/7/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    kEventTypeDiagnostic = 0,
    kEventTypeRecord = 1
} kEventType;

@class Soldier;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * finalScore;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * pushUp;
@property (nonatomic, retain) NSNumber * run;
@property (nonatomic, retain) NSNumber * sitUp;
@property (nonatomic, retain) NSNumber * testType;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Soldier *soldier;

@end

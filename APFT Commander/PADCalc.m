//
//  apftDataModel.m
//  APFTcdr
//
//  Created by Felipe on 7/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PADCalc.h"

@implementation PADCalc
static BOOL loggingEnabledSU = NO;
static BOOL loggingEnabledPU = NO;
static BOOL loggingEnabledRun = NO;
static BOOL loggingEnabled = NO;

+(NSNumber*)cStringToNum:(NSString*)string{
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterNoStyle];
	
	NSNumber * myNumber = [f numberFromString:string];

	return myNumber;
}
+(NSString*)cNumToString:(NSNumber*)number{
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterNoStyle];
	
	NSString * myString = [f stringFromNumber:number];
	
	return myString;
}

+(NSDictionary *)loadDataModel:(NSNumber *)age {
    
	//Get path for static resources of program
	
	//This is my load step for the APFT Tables
	NSString *dataModelPath = [[NSString alloc] init];
    
    switch ([age intValue]) {
        case 1 ... 21:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"17" ofType:@"plist"];
            break;
        case 22 ... 26:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"22" ofType:@"plist"];
            break;
        case 27 ... 31:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"27" ofType:@"plist"];
            break;
        case 32 ... 36:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"32" ofType:@"plist"];
            break;
        case 37 ... 41:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"37" ofType:@"plist"];
            break;
        case 42 ... 46:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"42" ofType:@"plist"];
            break;
        case 47 ... 51:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"47" ofType:@"plist"];
            break;
        case 52 ... 56:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"52" ofType:@"plist"];
            break;
        case 57 ... 61:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"57" ofType:@"plist"];
            break;
        case 62 ... 100:
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"62" ofType:@"plist"];
            break;
        default:
            //No age means you get a 17-year old's results.
            dataModelPath = [[NSBundle mainBundle] pathForResource:@"17" ofType:@"plist"];
            break;
    }
    loggingEnabled ? NSLog(@"Loading plist: %@", dataModelPath) : nil;
    
    return [NSMutableDictionary dictionaryWithContentsOfFile:dataModelPath];

}

//Get Run
+(NSNumber *)getRun:(NSString *)rawScore soldierAge:(NSNumber *)age soldierSex:(NSString *)sex {

	
	NSNumber *intRawScore = [self cStringToNum:rawScore];
	NSNumber *currentScore = [NSNumber numberWithInt:[rawScore intValue]];
	
	
		/////////////////////RUN EVENT/////////////////////
		NSDictionary *dataModel = [PADCalc loadDataModel:age];
		NSNumber *max = [self getMaxRun:sex soldierAge:age];
		
		//int maxMin = 0;
		//int maxSec = 0;
		int csMin = 0;
		int csSec = 0;
		int totalMin = 0;
		int totalSec = 0;
		
		NSString *maxString = [NSString stringWithString:[self cNumToString:max]];
		NSString *currentScoreString = [NSString stringWithString:[self cNumToString:currentScore]];
		
		
		
		if ([intRawScore intValue] <= [max intValue] && [intRawScore intValue] > 0) {
			//Score is eligible for extended scale. Find the difference
			
			//Separating Minutes and Seconds to perform calculations
			//Ranges are (charIndex, length)
			NSString *maxMin = [[NSString alloc] initWithString:[maxString substringWithRange:NSMakeRange(0,2)]];
            loggingEnabledRun ? NSLog(@"Max Minutes: %@",maxMin) : nil;
			NSString *maxSec = [[NSString alloc] initWithString:[maxString substringWithRange:NSMakeRange(2,2)]];
            loggingEnabledRun ? NSLog(@"Max Seconds: %@",maxSec) : nil;
            NSString *currentScoreMin, *currentScoreSec;
            
			if ([currentScoreString length] == 4) {
				currentScoreMin = [[NSString alloc] initWithString:[currentScoreString substringWithRange:NSMakeRange(0,2)]];
				currentScoreSec = [[NSString alloc] initWithString:[currentScoreString substringWithRange:NSMakeRange(2,2)]];
				
				
			} else if ([currentScoreString length] == 3) {
				currentScoreMin = [[NSString alloc] initWithString:[currentScoreString substringWithRange:NSMakeRange(0,1)]];
                currentScoreSec = [[NSString alloc] initWithString:[currentScoreString substringWithRange:NSMakeRange(1,2)]];
                
			}
            loggingEnabledRun ? NSLog(@"Current Minutes: %@",currentScoreMin) : nil;
            loggingEnabledRun ? NSLog(@"Current Seconds: %@",currentScoreSec) : nil;
            csMin = [[self cStringToNum:currentScoreMin] intValue];
            csSec = [[self cStringToNum:currentScoreSec] intValue];
            
			//Converting strings to ints
			int intMin = [[self cStringToNum:maxMin] intValue];
			int intSec = [[self cStringToNum:maxSec] intValue];
			
			
			
			//If current score is greater than max score, borrow from 
			if (csSec > intSec) {
				//Subtract 1 minute from the minute and borrow 60 seconds
				//1 represents the minutes position
				//60 represents the seconds
				intMin -= 1;
				intSec += 60;
				
				//subtract the seconds
				totalSec = intSec - csSec;
			}
			
			//subtract the minutes
			totalMin = intMin - csMin;
			
			//convert the minutes to seconds
			totalMin = totalMin * 60;
			
			//add the newly converted minutes to the seconds
			totalSec = totalSec + totalMin;
			
			int extraPoints = (totalSec / 6) + 100;
			
			return [NSNumber numberWithInt:extraPoints];
			
		} else if ([intRawScore intValue] == 0) {
			
			currentScore = [NSNumber numberWithInt:0];
			return currentScore;
			
		} else if ([intRawScore intValue] > [max intValue]) {
			int startTime = [intRawScore intValue];
			//TODO: Get min run. If currentScore >= min run
			//min run should be 0 value
			currentScore = nil;
			while (currentScore == nil){
				NSNumber *counter = [NSNumber numberWithInt:startTime];
				currentScore = [[[dataModel objectForKey:sex] objectForKey:@"RUN"] objectForKey:[self cNumToString:counter]];
                loggingEnabledRun ? NSLog(@"Searching Run Times: %@  Found Score: %@",counter,currentScore) : nil;

				startTime = startTime - 1;
			}
			return currentScore;
		}
		/////////////////////RUN EVENT/////////////////////
		
		

	
	return currentScore;
}

//Get Push Up
+(NSNumber *)getPU:(NSString *)rawScore soldierAge:(NSNumber *)age soldierSex:(NSString *)sex; {
	NSNumber *intRawScore = [self cStringToNum:rawScore];
	
    NSDictionary *dataModel = [PADCalc loadDataModel:age];
    NSNumber * max = [self getMaxPU:sex soldierAge:age];
	NSNumber *currentScore = [[NSNumber alloc] init];
	if ([intRawScore intValue] >= [max intValue] && [intRawScore intValue] > 0) {
		//PU Extended Scale
		int x = [intRawScore intValue];
		int y = [max intValue];
		x = (x - y) + 100;
		currentScore = [NSNumber numberWithInt:x];
		return currentScore;
		
	} else if ([intRawScore intValue] == 0) {
			
			currentScore = [NSNumber numberWithInt:0];
			return currentScore;
		
	} else if ([intRawScore intValue] < [max intValue]) {
		int startRep = [intRawScore intValue];
		while (currentScore == nil){
			NSNumber *counter = [NSNumber numberWithInt:startRep];
			currentScore = [[[dataModel objectForKey:sex] objectForKey:@"PU"] objectForKey:[self cNumToString:counter]];
            loggingEnabledPU ? NSLog(@"Searching PU Repetition: %@  Found Score: %@",counter,currentScore) : nil;
            startRep = startRep + 1;
		}
		return currentScore;
	}
	return 0;
}
//Get Sit Up
+(NSNumber *)getSU:(NSString *)rawScore soldierAge:(NSNumber *)age soldierSex:(NSString *)sex; {
	NSNumber *intRawScore = [self cStringToNum:rawScore];
	
    NSDictionary *dataModel = [PADCalc loadDataModel:age];
    NSNumber *max = [self getMaxSU:sex soldierAge:age];
	NSNumber *currentScore = [[NSNumber alloc] init];
	if ([intRawScore intValue] >= [max intValue] && [intRawScore intValue] > 0) {
		//SU Extended Scale
		int x = [intRawScore intValue];
		int y = [max intValue];
		x = (x - y) + 100;
		currentScore = [NSNumber numberWithInt:x];
		return currentScore;
		
	} else if ([intRawScore intValue] == 0) {
		
        currentScore = [NSNumber numberWithInt:0];
		return currentScore;
		
	} else if ([intRawScore intValue] < [max intValue]) {
		int startRep = [intRawScore intValue];
		while (currentScore == nil){
			NSNumber *counter = [NSNumber numberWithInt:startRep];
			currentScore = [[[dataModel objectForKey:sex] objectForKey:@"SU"] objectForKey:[self cNumToString:counter]];
            loggingEnabledSU ? NSLog(@"Searching SU Repetition: %@  Found Score: %@",counter,currentScore) : nil;

			startRep = startRep + 1;
		}
		return currentScore;
	}
	return 0;
}

+(NSNumber *)compileScore:(NSNumber *)finalRun scorePU:(NSNumber *)finalPU scoreSU:(NSNumber *)finalSU soldierSex:(NSString *)sex{
	int _finalRun = [finalRun intValue];
	int _finalPU = [finalPU intValue];
	int _finalSU = [finalSU intValue];
	int _finalScore = 0;
	
	if (_finalRun >= 100 && _finalPU >= 100 && _finalSU >= 100) {
		//Extended scale calculation
		/*
        UIAlertView *alertDialog;
		alertDialog = [[UIAlertView alloc]
					   initWithTitle:@"X-Scale Notification" 
					   message:@"Congratulations Stud. \n Your Commander should grant you a pass." 
					   delegate:nil 
					   cancelButtonTitle:@"HOOAH!" 
					   otherButtonTitles:nil				   
					   ];
		[alertDialog show];
		[alertDialog release];
		
		return [NSNumber numberWithInt:(_finalRun + _finalPU + _finalSU)];
        */
	} 
	
	//Alert the user that the x-scale will not be used.
	if (_finalRun >= 100 || _finalPU >= 100 || _finalSU >= 100) {
		/*
        UIAlertView *alertDialog;
		alertDialog = [[UIAlertView alloc]
					   initWithTitle:@"X-Scale Notification" 
					   message:@"I detected a score above 100. \n However, not all scores were above 100. \n I will not compute the extended scale." 
					   delegate:nil 
					   cancelButtonTitle:@"Alright" 
					   otherButtonTitles:nil				   
					   ];
		[alertDialog show];
		[alertDialog release];
         */
	}
	
	//Score is not eligible for x-scale. Reset to 100 if >= 100
	if (_finalRun != 0) {
		if (_finalRun >= 100) {
			_finalScore = _finalScore + 100;
		} else {
			_finalScore = _finalScore + _finalRun;
		}
	}
	
	if (_finalPU != 0) {
		
		if (_finalPU >= 100) {
			_finalScore = _finalScore + 100;
		} else	{
			_finalScore = _finalScore + _finalPU;
		}
	}
	
	if (_finalSU != 0) {
		if (_finalSU >= 100) {
			_finalScore = _finalScore + 100;
		} else {
			_finalScore = _finalScore + _finalSU;
		}

			
	}
	
	if (_finalScore != 0) {
		return [NSNumber numberWithInt:_finalScore];
	}
	
	
	return [NSNumber numberWithInt:_finalScore];
	
	
	
}

//Get Max Cardio
+(NSNumber *)getMaxAltCardio:(NSString *)event soldierSex:(NSString *)sex soldierAge:(NSNumber *)age{
    NSDictionary *dataModel = [PADCalc loadDataModel:age];
    
    NSNumber *maxScore = [NSNumber numberWithInt:[[[[dataModel objectForKey:sex] objectForKey:event] objectForKey:@"MAX"] intValue]];
    
    return maxScore;
}

//Get Max Run - Get Max Run - Get Max Run - Get Max Run - Get Max Run - Get Max Run
+(NSNumber *)getMaxRun:(NSString *)sex soldierAge:(NSNumber *)age {
    NSDictionary *dataModel = [PADCalc loadDataModel:age];
    
    int maxScore = 100;
	NSNumber *currentScore = [NSNumber numberWithInt:0];
	NSNumber *runMax = [NSNumber numberWithInt:0];
    int startTime = 0;
	if ([sex isEqualToString:@"Male"]) {
		startTime = 1543;
	} else {
		startTime = 2001;
	}
    
    while ([currentScore intValue] != maxScore){
        NSNumber *counter = [NSNumber numberWithInt:startTime];
        currentScore = [[[dataModel objectForKey:sex] objectForKey:@"RUN"] objectForKey:[self cNumToString:counter]];
        runMax = counter;
        loggingEnabledRun ? NSLog(@"Searching for 100 in the Run... %@, %@",counter,currentScore) : nil;

        startTime = startTime -1;
    }
	
	return runMax;
}

//Get Max Push Up
+(NSNumber *)getMaxPU:(NSString *)sex soldierAge:(NSNumber *)age {
    NSDictionary *dataModel = [PADCalc loadDataModel:age];
    
    int maxScore = 100;
	NSNumber *currentScore = [NSNumber numberWithInt:0];
	NSNumber *puMax = [NSNumber numberWithInt:0];
    int startRep = 0;
	if ([sex isEqualToString:@"Male"]) {
		startRep = 49;
	} else {
		startRep = 24;
	}
    while ([currentScore intValue] != maxScore){
        NSNumber *counter = [NSNumber numberWithInt:startRep];
        currentScore = [[[dataModel objectForKey:sex] objectForKey:@"PU"] objectForKey:[self cNumToString:counter]];
        puMax = counter;
        loggingEnabledPU ? NSLog(@"Searching for 100 in the PU... %@, %@",counter,currentScore) : nil;

        startRep = startRep + 1;
    }
	
	return puMax;
}
//Get Max Sit Up
+(NSNumber *)getMaxSU:(NSString *)sex soldierAge:(NSNumber *)age {
    NSDictionary *dataModel = [PADCalc loadDataModel:age];
    
    int maxScore = 100;
	NSNumber *currentScore = [NSNumber numberWithInt:0];
	NSNumber *suMax = [NSNumber numberWithInt:0];
    int startRep = 62;
	while ([currentScore intValue] != maxScore){
        NSNumber *counter = [NSNumber numberWithInt:startRep];
        currentScore = [[[dataModel objectForKey:sex] objectForKey:@"SU"] objectForKey:[self cNumToString:counter]];
        suMax = counter;
        loggingEnabledSU ? NSLog(@"Searching for 100 in the SU... %@, %@",counter,currentScore) : nil;
        startRep = startRep + 1;
    }
	return suMax;
}

@end

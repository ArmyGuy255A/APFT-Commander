//
//  apftDataModel.h
//  APFTcdr
//
//  Created by Felipe on 7/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PADCalc : NSObject
+(NSDictionary *)loadDataModel:(NSNumber *)age;

+(NSNumber*)cStringToNum:(NSString*)string;
+(NSString*)cNumToString:(NSNumber*)number;

+(NSNumber *)getRun:(NSString *)rawScore soldierAge:(NSNumber *)age soldierSex:(NSString *)sex;
+(NSNumber *)getPU:(NSString *)rawScore soldierAge:(NSNumber *)age soldierSex:(NSString *)sex;
+(NSNumber *)getSU:(NSString *)rawScore soldierAge:(NSNumber *)age soldierSex:(NSString *)sex;
+(NSNumber *)getMaxAltCardio:(NSString *)event soldierSex:(NSString *)sex soldierAge:(NSNumber *)age;
+(NSNumber *)getMaxRun:(NSString *)sex soldierAge:(NSNumber *)age;
+(NSNumber *)getMaxPU:(NSString *)sex soldierAge:(NSNumber *)age;
+(NSNumber *)getMaxSU:(NSString *)sex soldierAge:(NSNumber *)age;
+(NSNumber *)compileScore:(NSNumber *)finalRun scorePU:(NSNumber *)finalPU scoreSU:(NSNumber *)finalSU soldierSex:(NSString *)sex;

@end

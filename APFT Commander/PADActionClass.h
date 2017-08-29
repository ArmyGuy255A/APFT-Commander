//
//  PADActionClass.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/4/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>


@interface PADActionClass : NSObject

+(NSNumber *)cStringToNum:(NSString *)string;
+(NSString *)cNumToString:(NSNumber *)number;
+(NSNumber *)randBetween:(int)low and:(int)high;
+(NSString *)getDeviceModelName;
@end


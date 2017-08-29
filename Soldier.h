//
//  Soldier.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/7/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Soldier : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSSet *events;
@end

@interface Soldier (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end

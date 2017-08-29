//
//  PADSoldierTableViewController.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/4/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Soldier.h"


@interface PADSoldierTableViewController : UITableViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

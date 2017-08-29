//
//  PADEventTableViewController.h
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/7/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Event.h"

@interface PADEventTableViewController : UITableViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

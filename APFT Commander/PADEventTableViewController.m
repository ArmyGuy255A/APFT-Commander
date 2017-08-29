//
//  PADEventTableViewController.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/7/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import "PADEventTableViewController.h"
#import "PADEventTableViewCell.h"
#import "PADEventInfoViewController.h"
#import "Soldier.h"

@implementation PADEventTableViewController

-(void)viewDidLoad {
    [self setTitle:@"Events"];
    self.tableView.delegate = self;
    
    //UIBarButtonItem *addEventButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    //[self.navigationItem setRightBarButtonItem:addEventButton];
    
}

#pragma mark - Fetched Results Controller Delegate
//Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

//Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

//Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
//The fetched results controller reports changes to its section before changes to the fetch result objects.
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            //save the context when you delete a record.
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [controller.managedObjectContext save:nil];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
            //Reference the configureCell method to update the cell's context with the changes
            [self configureCell:cell withManagedObject:managedObject];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/* Notifies the receiver of the addition or removal of a section.
 The fetched results controller reports changes to its section before changes to the fetched result objects.
 This method may be invoked many times during an update event (for example, if you are importing data on a background thread and adding them to the context in a batch). You should consider carefully whether you want to update the table view on receipt of each message.
 */
-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
            
    }
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Perform a check to either open another instance of the table view or the info view. Check the children on the Events for the current indexPath
    [self performSegueWithIdentifier:@"PADEventInfoViewController" sender:indexPath];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSMutableString *dateString = [[NSMutableString alloc] initWithString:[sectionInfo name]];
    
    [dateString deleteCharactersInRange:NSMakeRange(10, dateString.length -10)];

    //Format the title
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:@"yyy-MMM-dd"];

    return [dateFormatter stringFromDate:date];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PADEventTableViewCell";
    
    PADEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PADEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Init with Core Data
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withManagedObject:managedObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)configureCell:(UITableViewCell *)cell withManagedObject:(NSManagedObject *)managedObject {
    Event *event = (Event *)managedObject;
    Soldier *soldier = [managedObject valueForKey:@"soldier"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@ %@",
                           [soldier valueForKey:@"lastName"],
                           [soldier valueForKey:@"firstName"],
                           [soldier valueForKey:@"rank"]];
    
    //Calculate the score for the event.
    NSString *testType;
    if (![event.testType boolValue]) {
        testType = @"Diagnostic";
    } else {
         testType = @"Record";
    }
    cell.detailTextLabel.text = testType;
    
}

#pragma mark - View Controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PADEventInfoViewController *viewController = segue.destinationViewController;
    //If sender is nil, then a new Soldier object must be created. Otherwise, it's looking for an NSIndexPath.
    if (sender) {
        //Reference the existing data
        viewController.event = [self.fetchedResultsController objectAtIndexPath:(NSIndexPath *)sender];
    } else {
        //Create a new Event
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSEntityDescription *eventEntity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Event"];
        viewController.event = [NSEntityDescription insertNewObjectForEntityForName:[eventEntity name] inManagedObjectContext:delegate.managedObjectContext];
    }
    
}

#pragma mark - Custom Implementation
-(void)addEvent {
    [self performSegueWithIdentifier:@"PADEventInfoViewController" sender:nil];
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    //Get the app delegate
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    /////////////////////
    //Set up the fetched results controller.
    /////////////////////
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Soldier" inManagedObjectContext:delegate.managedObjectContext];
    NSEntityDescription *entity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Event"];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO selector:@selector(compare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID='0x1234' AND favorite=%d",0];
    //[fetchRequest setPredicate:predicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSLog(@"Creating the FRC for == DetailTVC ==");
    
    [NSFetchedResultsController deleteCacheWithName:@"EventCache"];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:delegate.managedObjectContext sectionNameKeyPath:@"date" cacheName:@"EventCache"];
    _fetchedResultsController.delegate = self;
    
    //NSLog(@"Executing Fetch Request with == DetailTVC moc- %@", [self.fetchedResultsController.managedObjectContext description]);
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Core Data Error"
                                                                       message:[NSString stringWithFormat:@"There was an error performing the following fetch: /nEntity Name:%@/n", entity.name]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    self.fetchedResultsController = _fetchedResultsController;
    
    
    return _fetchedResultsController;
}

@end

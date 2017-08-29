//
//  PADSoldierTableViewController.m
//  APFT Commander
//
//  Created by Phillip Dieppa on 12/4/14.
//  Copyright (c) 2014 Phillip Dieppa. All rights reserved.
//

#import "PADSoldierTableViewController.h"
#import "PADSoldierTableViewCell.h"
#import "PADSoldierInfoViewController.h"
#import "Event.h"
#import "PADActionClass.h"
#import "PADCalc.h"

@implementation PADSoldierTableViewController

-(void)viewDidLoad {
    [self setTitle:@"Soldiers"];
    self.tableView.delegate = self;
    self.fetchedResultsController.fetchedObjects.count <= 0 ? [self createSampleData] : nil;
    
    UIBarButtonItem *addSoldierButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSoldier)];
    [self.navigationItem setRightBarButtonItem:addSoldierButton];
    
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
    [self performSegueWithIdentifier:@"PADSoldierInfoViewController" sender:indexPath];
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
    
    return [sectionInfo name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PADSoldierTableViewCell";
    
    PADSoldierTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PADSoldierTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@ %@",
                           [managedObject valueForKey:@"lastName"],
                           [managedObject valueForKey:@"firstName"],
                           [managedObject valueForKey:@"rank"]];
    
    NSSet *events = [managedObject valueForKey:@"events"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Events: %lu", (unsigned long)events.count];
}

#pragma mark - View Controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PADSoldierInfoViewController *viewController = segue.destinationViewController;
    //If sender is nil, then a new Soldier object must be created. Otherwise, it's looking for an NSIndexPath.
    if (sender) {
        //Reference the existing data
        viewController.soldier = [self.fetchedResultsController objectAtIndexPath:(NSIndexPath *)sender];
    } else {
        //Create a new Soldier
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSEntityDescription *soldierEntity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Soldier"];
        viewController.soldier = [NSEntityDescription insertNewObjectForEntityForName:[soldierEntity name] inManagedObjectContext:delegate.managedObjectContext];
    }

}

#pragma mark - Custom Implementation
-(void)addSoldier {
    [self performSegueWithIdentifier:@"PADSoldierInfoViewController" sender:nil];
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
    NSEntityDescription *entity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Soldier"];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *initialSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:initialSortDescriptor,sortDescriptor, nil];
    
    // Set the Predicate for only Parent and no favorite items
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID='0x1234' AND favorite=%d",0];
    //[fetchRequest setPredicate:predicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSLog(@"Creating the FRC for == DetailTVC ==");
    
    [NSFetchedResultsController deleteCacheWithName:@"SoldierCache"];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:delegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"SoldierCache"];
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

-(void)createSampleData {
    //Add some data
    NSLog(@"Making some data. Please wait!");
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription *soldierEntity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Soldier"];
    NSArray *lastNames = [NSArray arrayWithObjects:@"Twiss",
                          @"Dieppa",
                          @"Brown",
                          @"Gutierrez",
                          @"Frieling",
                          @"Roberts",
                          @"Armour",
                          @"Doehling",
                          @"Epps",
                          @"Bradley",
                          @"Cruz",
                          @"Patterson",
                          @"Setters",
                          @"Ball",
                          @"Szkapi",
                          @"McGrady",
                          @"Durham",
                          @"Darnell",
                          nil];
    NSArray *firstNames = [NSArray arrayWithObjects:@"Claudia",
                           @"Phillip",
                           @"Lucas",
                           @"Jose",
                           @"Hannah",
                           @"Marc",
                           @"Kassiem",
                           @"Steven",
                           @"Kelvin",
                           @"Chastity",
                           @"Brenda",
                           @"Melvin",
                           @"Ernest",
                           @"Ethan",
                           @"Something",
                           @"Robert",
                           @"Chad",
                           @"Jessica",
                           nil];
    
    NSArray *sexes = [NSArray arrayWithObjects:@"Female",
                      @"Male",
                      @"Male",
                      @"Male",
                      @"Female",
                      @"Male",
                      @"Male",
                      @"Male",
                      @"Male",
                      @"Female",
                      @"Female",
                      @"Male",
                      @"Male",
                      @"Male",
                      @"Female",
                      @"Male",
                      @"Male",
                      @"Female",
                      nil];
    
    NSArray *ranks = [NSArray arrayWithObjects:@"SFC",
                      @"CW2",
                      @"CPT",
                      @"SSG",
                      @"SGT",
                      @"MSG",
                      @"CW2",
                      @"MAJ",
                      @"SGT",
                      @"SFC",
                      @"CPL",
                      @"SSG",
                      @"SSG",
                      @"SGT",
                      @"SPC",
                      @"CPL",
                      @"SGT",
                      @"SSG",
                      nil];
    
    for (int x = 0; x < lastNames.count; x++) {
        int age = arc4random_uniform(70);
        age < 12 ? age = 12 : age;
        
        Soldier *soldier = [NSEntityDescription insertNewObjectForEntityForName:[soldierEntity name] inManagedObjectContext:delegate.managedObjectContext];
        [soldier setLastName:[lastNames objectAtIndex:x]];
        [soldier setFirstName:[firstNames objectAtIndex:x]];
        [soldier setAge:[NSNumber numberWithInt:age]];
        [soldier setSex:[sexes objectAtIndex:x]];
        [soldier setRank:[ranks objectAtIndex:x]];
        
        //Generate Events
        int z = [[PADActionClass randBetween:1 and:10] intValue];
        for (int y = 0; y < z; y++) {
            Event *event = [self createSampleEvent:soldier.sex];
            [soldier addEventsObject:event];
        }
    }
    
    
    
    if ([delegate.managedObjectContext hasChanges]) {
        [delegate saveContext];
    }

}

-(Event *)createSampleEvent:(NSString *)gender {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription *eventEntity = [[delegate.managedObjectModel entitiesByName] objectForKey:@"Event"];
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:[eventEntity name] inManagedObjectContext:delegate.managedObjectContext];
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    [dateComponent setDay:[[PADActionClass randBetween:1 and:60] integerValue]];
    [event setDate:[[NSCalendar currentCalendar] dateByAddingComponents:dateComponent toDate:currentDate options:0]];
    [event setHeight:[PADActionClass randBetween:65 and:80]];
    [event setWeight:[PADActionClass randBetween:140 and:275]];
    [event setTestType:[PADActionClass randBetween:0 and:1]];
    NSString *runTime = [NSString stringWithFormat:@"%@%@%@", [PADActionClass randBetween:8 and:35], [PADActionClass randBetween:0 and:5], [PADActionClass randBetween:0 and:9]];
    [event setRun:[PADCalc cStringToNum:runTime]];
    [event setSitUp:[PADActionClass randBetween:30 and:100]];
    [event setPushUp:[PADActionClass randBetween:30 and:100]];
    [event setFinalScore:[PADCalc compileScore:event.run scorePU:event.pushUp scoreSU:event.sitUp soldierSex:gender]];
    
    
    return event;
}

@end

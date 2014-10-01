//
//  RootTableViewController.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 29/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "RootTableViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "Client.h"
#import "BeaconAdvertisingService.h"

@interface RootTableViewController ()

@property (strong, nonatomic) NSMutableArray         * events;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;


@end

@implementation RootTableViewController

///////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Enable iBeacon switch button only when iBeacon starts advertising
    self.iBeaconConnectButton.enabled = NO;
    [BeaconAdvertisingService sharedInstance].rootTblVC = self;
    
}


////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    [self fetchEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addRow:)
                                                 name:@"iPad received data"
                                               object:nil];
    
    
}


///////////////////////////////////////////
-(void)addRow:(NSNotification*)notification
{
    NSArray *nameArray = notification.userInfo[@"info"];
    
    if(nameArray)
    {
        Event  * event1  = nil;
        Client * client1 = nil;
        
        event1 = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                               inManagedObjectContext:self.managedObjectContext];
        
        client1 = [NSEntityDescription insertNewObjectForEntityForName:@"Client"
                                                inManagedObjectContext:self.managedObjectContext];
        client1.firstName = (NSString *)[nameArray firstObject];
        client1.lastName  = (NSString *)nameArray[1];
        
        event1.inOrOut = (NSNumber *)nameArray[2];
        event1.timestamp = [NSDate date];
        event1.client = client1;
        
        NSError* error0 = nil;
        if (![self.managedObjectContext save:&error0])
        {
            NSLog(@"Can't Save! %@ \r %@", error0, [error0 localizedDescription]);
        }
        
        //Update TableView DataSource
        [self.events insertObject:event1 atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        });
    }
}




-(void)fetchEvents
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    
    NSError *error = nil;
    self.events = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    [self.tableView reloadData];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *event = (Event*)[self.events objectAtIndex:indexPath.row];
    
    NSString *inOrOutString;
    
    if ([(NSNumber*)[(Event*)event inOrOut]  isEqual: @1])
        inOrOutString = @"entered";
    else
        inOrOutString = @"drew away";
    
    NSString* datePart = [NSDateFormatter localizedStringFromDate: event.timestamp
                                                        dateStyle: NSDateFormatterShortStyle
                                                        timeStyle: NSDateFormatterNoStyle];
    NSString* timePart = [NSDateFormatter localizedStringFromDate: event.timestamp
                                                        dateStyle: NSDateFormatterNoStyle
                                                        timeStyle: NSDateFormatterMediumStyle];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ just %@ the area at %@", event.client.firstName, event.client.lastName, inOrOutString, timePart];
    
}


//////////////////////////////////////////////////////////////////////////////////////////
# pragma mark - Storyboard methods
//////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)clearAllBarButtonClick:(id)sender
{
    //FETCH ALL EVENTS IN CORE DATA
    NSFetchRequest *request     = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    NSError *error = nil;
    NSArray *objectsToBeDeleted = [self.managedObjectContext executeFetchRequest:request
                                                                           error:&error];
    //SI IL Y EN A, ON LES SUPPRIME
    if (! [objectsToBeDeleted count] == 0)
    {
        for (NSManagedObject* objectToBeDeleted in objectsToBeDeleted)
            [self.managedObjectContext deleteObject:objectToBeDeleted];
    }
    
    //Save context
    NSError *error2 = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Can't Save! %@ \r %@", error2, [error2 localizedDescription]);
    }
    
    //On clear aussi le tableView
    self.events = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    
}



- (IBAction)iBeaconConnectButtonClick:(id)sender
{
    if ([[BeaconAdvertisingService sharedInstance] isAdvertising])
    {
        [[BeaconAdvertisingService sharedInstance] stopAdvertising];
        [self.iBeaconConnectButton setTitle:@"Start iBeacon Advertising"];
    }
    else
    {
        NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
        [[BeaconAdvertisingService sharedInstance] startAdvertisingUUID:plasticOmiumUUID major:0 minor:0];
        [self.iBeaconConnectButton setTitle:@"Stop iBeacon Advertising"];
    }
    
}

@end

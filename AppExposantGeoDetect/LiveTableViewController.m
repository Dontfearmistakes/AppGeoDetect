//
//  LiveTableViewController.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 29/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "LiveTableViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "Client.h"
#import "BeaconAdvertisingService.h"
#import "LiveVCCell.h"

@interface LiveTableViewController ()

@property (strong, nonatomic) NSMutableArray         * events;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end

@implementation LiveTableViewController

///////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [BeaconAdvertisingService sharedInstance].liveTblVC = self;
    [UIApplication sharedApplication].idleTimerDisabled = YES;

}


////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    //On fetch et reload le TblView...
    
    //1) Au lancement de la vue
    [self fetchDataAndReloadTbleView];
    
    //2) Dès qu'une update intervient
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchDataAndReloadTbleViewWithEvent:)
                                                 name:@"iPad received data"
                                               object:nil];
}


-(void)fetchDataAndReloadTbleView
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    
    NSError *error = nil;
    self.events = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    if(self.events)
    {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           //Update TableView
                           [self.tableView reloadData];
                       });
    }
    
}

-(void)fetchDataAndReloadTbleViewWithEvent:(NSNotification*) notif
{
    Event *incomingEvent = notif.userInfo[@"event"];
    
    if(incomingEvent)
            {
        
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   //Update TableView DataSource
                                   [self.events insertObject:incomingEvent atIndex:0];
                                   //Update TableView
                                   [self.tableView beginUpdates];
                                   [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                                         withRowAnimation:UITableViewRowAnimationFade];
                                   [self.tableView endUpdates];
                               });
            }

    
//    [self.events addObject:notif.userInfo[@"event"]];
//    
//    [self.tableView reloadData];
}


//-(void)addRow:(NSNotification*)notification
//{
//    
//    NSArray *newEventFromNearbyIphoneArray = notification.userInfo[@"dataForLiveTbleVC"];
//    
//    if(newEventFromNearbyIphoneArray)
//    {
//        //Update TableView DataSource
//        [self.events insertObject:newEventFromNearbyIphoneArray atIndex:0];
//        
//        dispatch_async(dispatch_get_main_queue(),
//                       ^{
//                           [self.tableView beginUpdates];
//                           [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
//                                                 withRowAnimation:UITableViewRowAnimationFade];
//                           [self.tableView endUpdates];
//                       });
//    }
//}


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
    LiveVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
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
    
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ just %@ the area at %@", event.client.firstName, event.client.lastName, inOrOutString, timePart];
    cell.nameLabel.text = event.client.lastName;
    cell.hourLabel.text = timePart;
    cell.inOutLabel.text = inOrOutString;
    
    return cell;
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
        [self.iBeaconConnectButton setTitle:@"Démarrer iBeacon" forState:UIControlStateNormal];
    }
    else
    {
        NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
        [[BeaconAdvertisingService sharedInstance] startAdvertisingUUID:plasticOmiumUUID major:0 minor:0];
        [self.iBeaconConnectButton setTitle:@"Stopper iBeacon" forState:UIControlStateNormal];
    }
    
}

@end

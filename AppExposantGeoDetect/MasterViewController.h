//
//  MasterViewController.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearAllBarButton;
- (IBAction)clearAllBarButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *iBeaconConnectButton;
- (IBAction)iBeaconConnectButtonClick:(id)sender;

@end

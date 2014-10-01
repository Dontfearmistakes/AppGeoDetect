//
//  RootTableViewController.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 29/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearAllBarButton;
- (IBAction)clearAllBarButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *iBeaconConnectButton;
- (IBAction)iBeaconConnectButtonClick:(id)sender;

@end

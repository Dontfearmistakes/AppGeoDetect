//
//  LiveTableViewController.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 29/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearAllBarButton;
- (IBAction)clearAllBarButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *iBeaconConnectButton;
- (IBAction)iBeaconConnectButtonClick:(id)sender;





@end

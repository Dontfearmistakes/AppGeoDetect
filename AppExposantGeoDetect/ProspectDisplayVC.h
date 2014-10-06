//
//  ProspectDisplayVC.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 03/10/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProspectChoiceTableVC.h"
#import "Client.h"

@interface ProspectDisplayVC : UIViewController <ProspectChoiceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) Client *client;
@property (weak, nonatomic) IBOutlet UILabel *prospectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *prospectSocieteLabel;
@property (weak, nonatomic) IBOutlet UILabel *prospectTitreLabel;
@property (weak, nonatomic) IBOutlet UILabel *prospectEmailLabel;

-(void)updateLabels;

@end

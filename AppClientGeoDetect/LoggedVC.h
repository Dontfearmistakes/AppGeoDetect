//
//  loggedVC.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoggedVC : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *enterRegionLabel;
@property (weak, nonatomic) IBOutlet UILabel *determineRegionStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromNearToFarUILabel;

- (IBAction)clickOnDisconnectButton:(id)sender;





@end

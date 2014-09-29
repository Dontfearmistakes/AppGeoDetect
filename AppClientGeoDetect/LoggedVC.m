//
//  LoggedVC.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "LoggedVC.h"
#import <GSKeychain/GSKeychain.h>
#import "AppDelegate.h"
#import "BeaconMonitoringService.h"

@interface LoggedVC ()

@end

@implementation LoggedVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Ecoute les notif déclenchées lorsqu'on trouve des iBeacons
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iphoneDidEnterRegionUIUpdate:)
                                                 name:@"DidEnterRegion"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iphoneDidExitRegionUIUpdate:)
                                                 name:@"DidExitRegion"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iphoneDidDetermineRegionUIUpdate:)
                                                 name:@"DidDetermineRegionState"
                                               object:nil];
}

-(void)iphoneDidEnterRegionUIUpdate:(NSNotification*)notif
{
    //Update UI
    self.enterRegionLabel.text = [NSString stringWithFormat:@"didEnter : %@", notif.userInfo[@"stand"]]  ;
}
-(void)iphoneDidExitRegionUIUpdate:(NSNotification*)notif
{
    //Update UI
    self.enterRegionLabel.text = [NSString stringWithFormat:@"didExit : %@", notif.userInfo[@"stand"]]  ;
}
-(void)iphoneDidDetermineRegionUIUpdate:(NSNotification*)notif
{
    //Update UI
    self.determineRegionStateLabel.text = [NSString stringWithFormat: @"didDetermine : state : %@ - uuid : %@", (NSNumber *)notif.userInfo[@"state"], notif.userInfo[@"prox UUID"]];
}


// Choix d'afficher le lggedVC ou le loginVC ??
// Le Keychain est il rempli ou vide ??
-(void)viewWillAppear:(BOOL)animated
{
    // Is there a firstname/lastname in the keychain ?
    NSString *firstnameInKC = [NSString stringWithFormat:@"%@",[[GSKeychain systemKeychain] secretForKey:@"firstName"] ];
    
    // If not loginVC
    if ([firstnameInKC isEqualToString:@"(null)"])
    {
        UIStoryboard     * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * loginVC    = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
                           loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self.navigationController presentViewController:loginVC animated:NO completion:nil];
        
    }
    // Si oui loggedVC
    else
    {
        self.firstNameLastNameLabel.text = [NSString stringWithFormat:@"%@ %@", [[GSKeychain systemKeychain] secretForKey:@"firstName"],
                                                                                [[GSKeychain systemKeychain] secretForKey:@"lastName"]];
    }

}



- (IBAction)clickOnDisconnectButton:(id)sender
{
    [[GSKeychain systemKeychain] removeAllSecrets];
    [[BeaconMonitoringService sharedInstance] stopMonitoringAllRegions];
}




@end

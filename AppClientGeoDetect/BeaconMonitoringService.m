//
//  BeaconMonitoringService.m
//  Aroma
//
//  Created by Chris Wagner on 8/12/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "BeaconMonitoringService.h"
#import "AppDelegate.h"
#import <GSKeychain/GSKeychain.h>

NSString * const kBeaconIdentifier = @"com.razeware.waitlist";

@implementation BeaconMonitoringService {
    CLLocationManager *_locationManager;
    CLRegionState      _previousCLRegionState;
}


+ (BeaconMonitoringService *)sharedInstance {
    static dispatch_once_t onceToken;
    static BeaconMonitoringService *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    return self;
}

- (void)startMonitoringBeaconWithUUID:(NSUUID *)uuid
                                major:(CLBeaconMajorValue)major
                                minor:(CLBeaconMinorValue)minor
                           identifier:(NSString *)identifier
                              onEntry:(BOOL)entry
                               onExit:(BOOL)exit
{
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
    region.notifyOnEntry = entry;
    region.notifyOnExit = exit;
    region.notifyEntryStateOnDisplay = YES;
    
    //Pour iOS8
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [_locationManager requestAlwaysAuthorization];
    }

    [_locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringAllRegions {
    
    for (CLRegion *region in _locationManager.monitoredRegions) {
        [_locationManager stopMonitoringForRegion:region];
    }
    
    self.isIBeaconConnected = NO;
}


////////////////////////////////////////////////////////////
#pragma location manager delegate methods
////////////////////////////////////////////////////////////

-(void)startBrowsingForPeers
{
    // Send FirstName/LastName infos via MPConnectivity
    // Is there a firstname/lastname in the keychain ?
    NSString *firstnameInKC = [NSString stringWithFormat:@"%@",[[GSKeychain systemKeychain] secretForKey:@"firstName"]];
    
    // If KeyChain not empty, start browsing
    if (![firstnameInKC isEqualToString:@"(null)"])
    {
        AppDelegate *appD = [[UIApplication sharedApplication] delegate];
        [appD startBrowsing];
    }
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        CLBeaconRegion * beaconRegion = (CLBeaconRegion *)region;
        NSDictionary   * userInfo     = @{@"stand": @"Plastic Omium",
                                          @"prox UUID":beaconRegion.proximityUUID.UUIDString,
                                          @"state": @(state)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDetermineRegionState" object:self userInfo:userInfo];
        
        //Temporary Trick - DidEnterRegion pas appelé alors qu'on veut qu'il le soit
        //Mais quand DidDetermineState est appelé c'est qu'un iBeacon est détecté
        if ((_previousCLRegionState == CLRegionStateOutside && state == CLRegionStateInside)
            ||
            (_previousCLRegionState == CLRegionStateUnknown && state == CLRegionStateInside)
            ||
            (_previousCLRegionState == CLRegionStateInside && state == CLRegionStateInside))
        {
            [self locationManager:_locationManager didEnterRegion:region];
        }

        _previousCLRegionState = state;
    }
}



- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        self.isIBeaconConnected = YES;
        
        CLBeaconRegion      *beaconRegion = (CLBeaconRegion *)region;
        //1) On émet immédiatement une notif locale...
        UILocalNotification *notification = [[UILocalNotification alloc] init];
                             notification.userInfo  = @{@"uuid": beaconRegion.proximityUUID.UUIDString};
                             notification.alertBody = [NSString stringWithFormat:@"Looks like you're near an iBeacon!"];
                             notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        //2) Une alerte à l'écran
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are near Plastic Omium "
                                                        message:@"Blabla"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //3) Une notif au NotifCenter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidEnterRegion"
                                                            object:self
                                                          userInfo:@{@"stand": [NSString stringWithFormat: @"stand avec UUID : %@", beaconRegion.proximityUUID.UUIDString]}];

        ////////////////////////////////////////////
        // IN iBEACON RANGE --> MPCONNECTIVITY /////
        ////////////////////////////////////////////
        NSArray *firstNameLastNameArray = [NSArray arrayWithObjects:[[GSKeychain systemKeychain] secretForKey:@"firstName"],
                                                                    [[GSKeychain systemKeychain] secretForKey:@"lastName"],
                                                                    @1,
                                                                    nil];
        //4) Envoi notif d'entrée à l'iPAD avec la data
        NSData      *toSend = [NSKeyedArchiver archivedDataWithRootObject:firstNameLastNameArray];
        AppDelegate *appD   = [[UIApplication sharedApplication] delegate];
                    [appD sendMPMessage:toSend];
        
    }
}



- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        self.isIBeaconConnected = NO;
        
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        
        //1) On émet immédiatement une notif locale...
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.userInfo  = @{@"uuid": beaconRegion.proximityUUID.UUIDString};
        notification.alertBody = [NSString stringWithFormat:@"Looks like you're leaving an iBeacon!"];
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
        //2) Et on poste une notif au NotifCenter
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidExitRegion"
                                                            object:self
                                                          userInfo:@{@"stand": [NSString stringWithFormat: @"stand avec UUID : %@", beaconRegion.proximityUUID.UUIDString]}];
        
        /////////////////////////////////////////////
        // OUT OF iBEACON RANGE --> MPCONNECTIVITY //
        /////////////////////////////////////////////
        NSArray *firstNameLastNameArray = [NSArray arrayWithObjects:[[GSKeychain systemKeychain] secretForKey:@"firstName"],
                                                                    [[GSKeychain systemKeychain] secretForKey:@"lastName"],
                                                                    @0,
                                                                    nil];
        //3) Envoi notif de sortie à l'iPAD avec la data
        NSData      * toSend = [NSKeyedArchiver archivedDataWithRootObject:firstNameLastNameArray];
        AppDelegate * appD   = [[UIApplication sharedApplication] delegate];
                     [appD sendMPMessage:toSend];
    }
}



- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring failed for this region : "
                                                    message:@"Blabla"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Start Monitoring iBeacon");
}



-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    #warning switch iBeacon/iPad
    NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
    
    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:plasticOmiumUUID
                                                                      major:0
                                                                      minor:0
                                                                 identifier:kBeaconIdentifier
                                                                    onEntry:YES
                                                                     onExit:YES];

//    NSUUID *iBeacon = [[NSUUID alloc] initWithUUIDString:@"85FC11DD-4CCA-4B27-AFB3-876854BB5C3B"];
//    
//    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:iBeacon
//                                                                      major:523
//                                                                      minor:220
//                                                                 identifier:kBeaconIdentifier
//                                                                    onEntry:YES
//                                                                     onExit:YES];

}

@end

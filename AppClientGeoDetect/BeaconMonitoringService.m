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

@interface BeaconMonitoringService ()

@property (assign) BOOL isInRegion;

@end

@implementation BeaconMonitoringService {
    CLLocationManager *_locationManager;
    CLRegionState      _previousCLRegionState;
    CLProximity        _previousCLBeaconProximity1;
    CLProximity        _previousCLBeaconProximity2;
    NSDate            *_previousTimeProspectLeftiBeaconRange;
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
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    
    self.isIBeaconConnected = NO;
    self.isInRegion         = NO;
}



////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
#pragma location manager delegate methods
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

-(void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"rangingBeaconsDidFail"
                                                    message:[NSString stringWithFormat:@"error : %@", [error localizedDescription]]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}




-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLProximity beaconProximity = [[beacons firstObject] proximity];
    
    NSString *toDisplay;
    switch (beaconProximity)
    {
        case CLProximityUnknown:
            toDisplay =@"CLProximityUnknown";
            break;
        case CLProximityImmediate:
            toDisplay =@"CLProximityImmediate";
            break;
        case CLProximityNear:
            toDisplay =@"CLProximityNear";
            break;
        case CLProximityFar:
            toDisplay =@"CLProximityFar";
            break;
            
        default:
            break;
    }
    
    
    //Show Proximity on Screen pour les tests
    self.loggedVC.fromNearToFarUILabel.text = toDisplay;
    
    
    // 2) if (iBEACON RANGE Passe de moyen à loin) --> MPCONNECTIVITY
    if ((beaconProximity == CLProximityFar && _previousCLBeaconProximity1 == CLProximityNear)
        ||
        (beaconProximity == CLProximityFar && _previousCLBeaconProximity2 == CLProximityNear))
    {
        
        //NE PAS RENVOYER UNE NOTIF SI LE PROSPECT EST DEJA SORTI DU RANGE IL A MOINS DE 3 MIN
        NSDate         *now                                                            = [NSDate date];
        NSTimeInterval  timeIntervalSincePreviousTimeProspectLeftiBeaconRangeInSeconds = [now timeIntervalSinceDate:_previousTimeProspectLeftiBeaconRange];
        if (timeIntervalSincePreviousTimeProspectLeftiBeaconRangeInSeconds > 0)
        {
            // UIAlertView
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"From near to far"
                                                            message:[NSString stringWithFormat:@"Proximity : %@", toDisplay]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            NSArray *dataToSendWhenLeaveArray = [NSArray arrayWithObjects:[[GSKeychain systemKeychain] secretForKey:@"lastName"],
                                               [[GSKeychain systemKeychain] secretForKey:@"email"],
                                               [[GSKeychain systemKeychain] secretForKey:@"societe"],
                                               [[GSKeychain systemKeychain] secretForKey:@"titre"],
                                               @0,
                                               nil];
            NSData      *toSend = [NSKeyedArchiver archivedDataWithRootObject:dataToSendWhenLeaveArray];
            AppDelegate *appD   = [[UIApplication sharedApplication] delegate];
            [appD sendMPMessage:toSend];
            
        }
        
        _previousTimeProspectLeftiBeaconRange = [NSDate date];
    }
    
    _previousCLBeaconProximity1 = beaconProximity;
    _previousCLBeaconProximity2 = _previousCLBeaconProximity1;
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
            // Attention que didEnterRegion n'ait pas déjà été appelé
            if (self.isInRegion == NO)
            {
                [self locationManager:_locationManager didEnterRegion:region];
            }
        }

        _previousCLRegionState = state;
    }
}





- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        self.isIBeaconConnected = YES;
        self.isInRegion         = YES;
        
        [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
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
        NSArray *dataToSendWhenEnterArray = [NSArray arrayWithObjects:[[GSKeychain systemKeychain] secretForKey:@"lastName"],
                                                                    [[GSKeychain systemKeychain] secretForKey:@"email"],
                                                                    [[GSKeychain systemKeychain] secretForKey:@"societe"],
                                                                    [[GSKeychain systemKeychain] secretForKey:@"titre"],
                                                                    @1,
                                                                    nil];
        //4) Envoi notif d'entrée à l'iPAD avec la data
        if ([[GSKeychain systemKeychain]secretForKey:@"lastName"])
            // Check if KeyChain not empty car didChangeAuthorizationStatus et donc startMonitoringBeaconWithUUID (see below)
            // est potentiellement appelée au lancement de l'app avant que le user ne register et on ne veut pas envoyer un message
            // à l'iPad tant que le Keychain est vide
        {
            NSData      *toSend = [NSKeyedArchiver archivedDataWithRootObject:dataToSendWhenEnterArray];
            AppDelegate *appD   = [[UIApplication sharedApplication] delegate];
                        [appD sendMPMessage:toSend];
        }
    }
}




- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        self.isIBeaconConnected = NO;
        self.isInRegion         = NO;
        
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
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
//    NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
//    
//    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:plasticOmiumUUID
//                                                                      major:0
//                                                                      minor:0
//                                                                 identifier:kBeaconIdentifier
//                                                                    onEntry:YES
//                                                                     onExit:YES];

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

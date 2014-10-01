//
//  BeaconAdvertisingService.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 19/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPConnectivityHandler.h"
#import "RootTableViewController.h"

@import CoreLocation;

@interface BeaconAdvertisingService : NSObject

@property (assign) BOOL isAdvertising;
@property (strong) MPConnectivityHandler *mpConnectHandler;
@property (strong, nonatomic) RootTableViewController* rootTblVC;

+ (BeaconAdvertisingService *)sharedInstance;


- (void)startAdvertisingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;
- (void)stopAdvertising;
- (void)switchIBeacon;

@end

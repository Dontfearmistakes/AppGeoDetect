//
//  AppDelegate.m
//  AppClientGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconMonitoringService.h"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[BeaconMonitoringService sharedInstance] stopMonitoringAllRegions];
    
    //Demande au user "voulez vous activer les notifs ?" (iOS 8 only)
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil];
    [application registerUserNotificationSettings:settings];
    
    //Start monitoring iBeacons
    
    #warning switch device
    //NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
    //
    //    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:ibeaconUUID
    //                                                                      major:0
    //                                                                      minor:0
    //                                                                 identifier:@"com.razeware.waitlist"
    //                                                                    onEntry:YES
    //                                                                     onExit:YES];
    
    NSUUID *ibeaconUUID = [[NSUUID alloc] initWithUUIDString:@"85FC11DD-4CCA-4B27-AFB3-876854BB5C3B"];
    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:ibeaconUUID
                                                                      major:523
                                                                      minor:220
                                                                 identifier:@"com.razeware.waitlist"
                                                                    onEntry:YES
                                                                     onExit:YES];

    
    return YES;
}
							


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

}

@end

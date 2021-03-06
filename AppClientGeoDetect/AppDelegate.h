//
//  AppDelegate.h
//  AppClientGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>



@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern NSString *const PeerConnectionAcceptedNotification;


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCPeerID *peerId;

@property (assign) BOOL       isMCStateSessionConnected;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) MCPeerID               *destinationPeerID;


-(void)startBrowsing;
-(void)sendMPMessage:(NSData*)data;

@end

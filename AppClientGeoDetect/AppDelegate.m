//
//  AppDelegate.m
//  AppClientGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconMonitoringService.h"


NSString *const DataReceivedNotification = @"com.razeware.apps.CardShare:DataReceivedNotification";
BOOL      const kProgrammaticDiscovery = YES;
NSString *const PeerConnectionAcceptedNotification = @"com.razeware.apps.CardShare:PeerConnectionAcceptedNotification";


@interface AppDelegate ()<MCSessionDelegate, MCNearbyServiceBrowserDelegate>

@property (strong, nonatomic) MCNearbyServiceBrowser *browser;

@property (assign) BOOL isConnecting;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ////////////////////////////////
    //MULTIPEER CONNECTIVITY////////
    ////////////////////////////////
    //1) Set up a peer
    NSString *peerName = [[UIDevice currentDevice] name];
    self.peerId = [[MCPeerID alloc] initWithDisplayName:peerName];
    
    //2) Set up a session
    self.session = [[MCSession alloc] initWithPeer:self.peerId
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
    

    self.session.delegate = self;
    
    

    

    
    /////////////////
    //iBEACON////////
    ////////////////
    [[BeaconMonitoringService sharedInstance] stopMonitoringAllRegions];
    
    //Demande au user "voulez vous activer les notifs ?" (iOS 8 only)
    #warning (un)comment when iOS7(8)
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil];
    [application registerUserNotificationSettings:settings];
    
    //Start monitoring iBeacons
    #warning switch iBeacon/iPad
    NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
    
        [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:plasticOmiumUUID
                                                                          major:0
                                                                          minor:0
                                                                     identifier:@"com.razeware.waitlist"
                                                                        onEntry:YES
                                                                         onExit:YES];
    
//        NSUUID *ibeaconUUID = [[NSUUID alloc] initWithUUIDString:@"85FC11DD-4CCA-4B27-AFB3-876854BB5C3B"];
//        [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:ibeaconUUID
//                                                                          major:523
//                                                                          minor:220
//                                                                     identifier:@"com.razeware.waitlist"
//                                                                        onEntry:YES
//                                                                         onExit:YES];

    
    return YES;
}



-(void)setUpBrowser
{
    //3 Set up a browser, programmatically
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerId serviceType:@"rw-cardshare"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}


#pragma mark MCNearbyServiceBrowserDelegate delegate methods
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Error browsing: %@", error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    //Pour n'envoyer qu'une seule invit (ne rentrer qu'une fois dans la boucle)
    if(!self.isConnecting)
    {
        self.isConnecting =YES;
        NSData *toSend = [@"toto" dataUsingEncoding:NSUTF8StringEncoding];
        [self.browser invitePeer:peerID toSession:self.session withContext:toSend timeout:100];
    }
    
    
    //multipeer comunication
    
    /*
     If the developer chooses to write their own discovery code (with
     NetServices, or the Bonjour C API directly), instead of using
     MCNearbyServiceAdvertiser/Browser or MCBrowserViewController, one can
     add a remote peer to a MCSession by following these steps:
     
     1. Exchange MCPeerID with the remote peer.  Start by serializing the
     MCPeerID object with NSKeyedArchiver, exchange the data with
     the remote peer, and then reconstruct the remote MCPeerID object
     with NSKeyedUnarchiver.
     2. Exchange connection data with the remote peer.  Start by calling the
     session's -nearbyConnectionDataForPeer:completionHandler: and send
     the connection data to the remote peer, once the completionHandler
     is called.
     3. When the remote peer's connection data is received, call the
     session's -connectPeer:withNearbyConnectionData: method to add the
     remote peer to the session.
     */
    
    
//    NSString *filePath        = [[NSBundle mainBundle] pathForResource:@"peerID" ofType:@"txt"];
//    MCPeerID *destinationPeer = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
//    [self.session nearbyConnectionDataForPeer:peerID withCompletionHandler:^(NSData *connectionData, NSError *error) {
//        if(!error && connectionData)
//        {
//            
//            [self.session connectPeer:peerID
//             withNearbyConnectionData:connectionData];
//            
//            //NSData *toSend = [@"toto" dataUsingEncoding:NSUTF8StringEncoding];
//            
//            [self.session sendData:connectionData
//                           toPeers:@[peerID]
//                          withMode:MCSessionSendDataReliable
//                             error:&error];
//            
//        }
//    }];

}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{

}


#pragma mark - MCSessionDelegate delegate methods

//Called when the state of a nearby peer changes.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    self.isConnecting = NO;

    if (state == MCSessionStateConnected && self.session)
    {
        // For programmatic discovery, send a notification to the custom browser
        // that an invitation was accepted.
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PeerConnectionAcceptedNotification
         object:nil
         userInfo:@{
                    @"peer": peerID,
                    @"accept" : @YES
                    }];
        
        NSData *toSend = [@"toto" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        [self.session sendData:toSend
                                    toPeers:self.session.connectedPeers
                                   withMode:MCSessionSendDataReliable
                                      error:&error];

    }
    else if (state == MCSessionStateNotConnected && self.session)
    {
        // For programmatic discovery, send a notification to the custom browser
        // that an invitation was declined.
        // Send only if the peers are not yet connected
        if (![self.session.connectedPeers containsObject:peerID]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:PeerConnectionAcceptedNotification
             object:nil
             userInfo:@{
                        @"peer": peerID,
                        @"accept" : @NO
                        }];
            
            //try to reconect
            [self browser:self.browser foundPeer:peerID withDiscoveryInfo:nil];
            
        }
    }
}


-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    if (certificateHandler != nil)
        certificateHandler(YES);
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{

    // Trigger a notification that data was received
    [[NSNotificationCenter defaultCenter] postNotificationName:DataReceivedNotification object:nil];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}









- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

}

@end

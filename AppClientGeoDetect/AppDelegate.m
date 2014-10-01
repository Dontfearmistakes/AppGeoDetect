//
//  AppDelegate.m
//  AppClientGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconMonitoringService.h"
#import <GSKeychain/GSKeychain.h>

NSString *const DataReceivedNotification = @"com.razeware.apps.CardShare:DataReceivedNotification";
NSString *const PeerConnectionAcceptedNotification = @"com.razeware.apps.CardShare:PeerConnectionAcceptedNotification";



@interface AppDelegate ()<MCSessionDelegate, MCNearbyServiceBrowserDelegate>

@property (assign) BOOL isConnecting;
@property (strong) NSData *pendingData;

@end



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Clear keychain on first run in case of reinstallation
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        
        // Delete values from keychain here
        [[GSKeychain systemKeychain] removeAllSecrets];
        
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
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
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    return YES;
}



-(void)startBrowsing
{
    // 3) Set up a browser, si c'est pas déjà fait auparavant
    if(!self.browser)
    {
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerId
                                                        serviceType:@"rw-cardshare"];
        self.browser.delegate = self;
    }
    
    [self.browser startBrowsingForPeers];
    NSLog(@"Start Browsing for Peer !");
    //Call back : -foundPeer
}




////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
#pragma mark MCNearbyServiceBrowserDelegate delegate methods
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    //isConnecting pour n'envoyer qu'une seule invit (un BOOL est à NO par défaut)
    if(!self.isConnecting)
    {
        
        [self.browser stopBrowsingForPeers];
         self.isConnecting =YES;
        
        NSLog(@"Found Peer, Invite Peer !");
        
        //Stocke DestinationPeerID pour éviter de devoir ré-inviter si besoin de renvoyer des infos plus tard
        self.destinationPeerID = peerID;
        
        [self.browser invitePeer:peerID
                       toSession:self.session
                     withContext:nil
                         timeout:100];
        //Call back : -sessionDidChangeState
    }
}
    
    - (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
    {
        
    }

    - (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
    {
        NSLog(@"Error browsing: %@", error.localizedDescription);
    }




////////////////////////////////////////////////
////////////////////////////////////////////////
#pragma mark - MCSessionDelegate delegate methods
////////////////////////////////////////////////
////////////////////////////////////////////////

    //Called when the state of a nearby peer changes.
    - (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
    {
        self.isConnecting = NO;
        
        NSString *toDisplay;
        switch (state)
        {
            case MCSessionStateConnected:
                toDisplay =@"MCSessionStateConnected";
                self.isMCStateSessionConnected = YES;
                break;
            case MCSessionStateConnecting:
                toDisplay =@"MCSessionStateConnecting";
                self.isMCStateSessionConnected = NO;
                break;
            case MCSessionStateNotConnected:
                toDisplay =@"MCSessionStateNotConnected";
                self.isMCStateSessionConnected = NO;
                break;
                
            default:
                break;
        }
        NSLog(@"state : %@", toDisplay);
        
        
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
            
            // NOW THAT WE ARE CONNECTED THROUGH MPCONNECTIVITY
            // LET'S SEND OUR FIRSTNAME/LASTNAME IF STATED
            if(self.pendingData)
            {
                [self sendMPMessage:self.pendingData];
            }
            
            
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
            }
        }
    }


    -(void)sendMPMessage:(NSData*)data;
    {
        // Si on notre destinationPeer est toujours connecté à notre MCSession
        // Alors on envoi direct
        if([[self.session connectedPeers] count] > 0)
        {
            NSError *error;
            [self.session sendData:data
                           toPeers:self.session.connectedPeers
                          withMode:MCSessionSendDataReliable
                             error:&error];
            
            if(error)
            {
                NSLog(@"unable to send message : %@",error.localizedDescription);
                self.pendingData = nil;
            }
            else
            {
                NSLog(@"message sent");
            }
        }
        // Si on à pas/plus de peer connecté à notre session
        else
        {
            // On enregistre la data pour pouvoir l'envoyer
            // avec sendData dès que la MPConnection aura abouti
            self.pendingData = data;
            self.isConnecting = NO;
            
            // Soit il nous reste le self.destinationPeerID d'une précedente connection
            // Du coup il suffit de ré-inviter
            if(self.destinationPeerID)
            {
                #pragma testing
                [self startBrowsing];
//                [self.browser invitePeer:self.destinationPeerID
//                               toSession:self.session
//                             withContext:nil
//                                 timeout:100];
                //Call back : -sessionDidChangeState
            }
            // Soit on a pas de self.destinationPeerID et on recommence tout avec un browse
            else
            {
                [self startBrowsing];
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

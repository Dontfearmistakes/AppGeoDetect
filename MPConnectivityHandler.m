//
//  MPConnectivityHandler.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 25/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "MPConnectivityHandler.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"


// Invitation handler definition
typedef void(^InvitationHandler)(BOOL accept, MCSession *session);
NSString *const DataReceivedNotification = @"com.razeware.apps.CardShare:DataReceivedNotification";
NSString *const kServiceType = @"rw-cardshare";

@interface MPConnectivityHandler ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate>

@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCPeerID *peerId;
@property (copy, nonatomic) InvitationHandler handler;

@end

@implementation MPConnectivityHandler


-(void)setUpPeerSessionAndStartAdvertising
{
    //1) Set up a peer
    NSString *peerName = [[UIDevice currentDevice] name];
    self.peerId = [[MCPeerID alloc] initWithDisplayName:peerName];




    //2) Set up a session
    self.session = [[MCSession alloc] initWithPeer:self.peerId
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];

    // Set the session delegate
    self.session.delegate = self;


    //3) Set up an advertiser programmatically
    if(!self.advertiser)
    {
    self.advertiser = [[MCNearbyServiceAdvertiser alloc]
                       initWithPeer:self.peerId
                       discoveryInfo:nil
                       serviceType:kServiceType];
    self.advertiser.delegate = self;
    }
    
    
    [self.advertiser startAdvertisingPeer];
    NSLog(@"Advertising MP!");
}



#pragma mark - MCNearbyServiceAdvertiserDelegate delegate methods
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    // Save the invitation handler for later use
    self.handler = invitationHandler;
    
    // Call the invitation handler
    self.handler(YES, self.session);
    
    #warning à voir si on laisse : [self.advertiser stopAdvertisingPeer];
    //[self.advertiser stopAdvertisingPeer];
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}



#pragma mark - MCSessionDelegate delegate methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
    NSString *toDisplay;
    
    switch (state) {
        case MCSessionStateConnected:
            toDisplay =@"MCSessionStateConnected";
            break;
        case MCSessionStateConnecting:
            toDisplay =@"MCSessionStateConnecting";
            break;
        case MCSessionStateNotConnected:
            toDisplay =@"MCSessionStateNotConnected";
            break;
            
        default:
            break;
    }
    
    
    
    NSLog(@"Ipad exposant state : %@", toDisplay);
    
    if (state == MCSessionStateConnected && self.session)
    {
        
        // For programmatic discovery, send a notification to the custom browser
        // that an invitation was accepted.
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"PeerConnectionAcceptedNotification"
         object:nil
         userInfo:@{
                    @"peer": peerID,
                    @"accept" : @YES
                    }];
    }
    else if (state == MCSessionStateNotConnected && self.session)
    {
        // For programmatic discovery, send a notification to the custom browser
        // that an invitation was declined.
        // Send only if the peers are not yet connected
        if (![self.session.connectedPeers containsObject:peerID]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PeerConnectionAcceptedNotification"
             object:nil
             userInfo:@{
                        @"peer": peerID,
                        @"accept" : @NO
                        }];
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{

    NSArray * firstNameLastNameInOrOutArray = [NSArray arrayWithArray: (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    if (firstNameLastNameInOrOutArray[0] && firstNameLastNameInOrOutArray[1] && firstNameLastNameInOrOutArray[2])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"iPad received data"
                                                            object:self userInfo:@{@"info":firstNameLastNameInOrOutArray}];
    }
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

@end

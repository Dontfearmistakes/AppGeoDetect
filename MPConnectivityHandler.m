//
//  MPConnectivityHandler.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 25/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "MPConnectivityHandler.h"

#import "AppDelegate.h"
#import "Event.h"
#import "Client.h"

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

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSMutableArray         * clients;
@property (assign)            BOOL                     hasAlreadyEntered;
@property (strong, nonatomic) Client                 * alreadyEnteredClient;
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
    // La data qui vient d'arriver
    NSArray * dataFromNearByIphoneArray = [NSArray arrayWithArray: (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    // Les clients qui sont déjà dans Core Data (il faut les refectcher à chaque fois pour voir si on connait déjà cette personne ou non)
                    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    NSError        *error   =  nil;
               self.clients = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    // 1) Dans tous les cas on crée un nouvel Event
    Event  * event1  = nil;
             event1  = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                           inManagedObjectContext:self.managedObjectContext];
    
    // Mais va-t-on ou non créer un nouveau Client ?
    self.hasAlreadyEntered = NO;
    for (Client* client in self.clients)
    {
        if ([(NSString*)client.email isEqualToString:(NSString *) dataFromNearByIphoneArray[1]])
        {
            self.hasAlreadyEntered    = YES;
            self.alreadyEnteredClient = client;
        }
    }
    
    // S'il existait déjà en base, non
    if (self.hasAlreadyEntered == YES)
    {
        event1.client    = self.alreadyEnteredClient;
        event1.inOrOut   = (NSNumber *)dataFromNearByIphoneArray[4];
        event1.timestamp = [NSDate date];
    }
    
    //Sinon oui
    else
    {
        Client * client1 = nil;
        client1 = [NSEntityDescription insertNewObjectForEntityForName:@"Client"
                                                inManagedObjectContext:self.managedObjectContext];
        
        client1.lastName = (NSString *)[dataFromNearByIphoneArray firstObject];
        client1.email    = (NSString *) dataFromNearByIphoneArray [1];
        client1.societe  = (NSString *) dataFromNearByIphoneArray [2];
        client1.titre    = (NSString *) dataFromNearByIphoneArray [3];

        event1.inOrOut   = (NSNumber *)dataFromNearByIphoneArray[4];
        event1.timestamp = [NSDate date];
        event1.client    = client1;
    }
    
    
    //On sauvegarde
    NSError* error0 = nil;
    if (![self.managedObjectContext save:&error0])
    {
        NSLog(@"Can't Save! %@ \r %@", error0, [error0 localizedDescription]);
    }
    
    
//    NSArray * dataToSendToLiveTblVC = @[[dataFromNearByIphoneArray firstObject],
//                                        event1.timestamp,
//                                        event1.inOrOut
//                                        ];
    
    // On notifie les ViewControllers pour qu'ils puissent s'updater
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iPad received data"
                                                        object:self
                                                      userInfo:@{@"event":event1}];
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

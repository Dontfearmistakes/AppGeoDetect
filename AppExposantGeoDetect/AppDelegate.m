//
//  AppDelegate.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconAdvertisingService.h"
#import "MasterViewController.h"
#import "Event.h"
#import "Client.h"

NSString *const kServiceType = @"rw-cardshare";
NSString *const DataReceivedNotification = @"com.razeware.apps.CardShare:DataReceivedNotification";
BOOL const kProgrammaticDiscovery = YES;

// Invitation handler definition
typedef void(^InvitationHandler)(BOOL accept, MCSession *session);

@interface AppDelegate ()<MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (copy, nonatomic) InvitationHandler handler;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
    
    // Set the session delegate
    self.session.delegate = self;
    
    
    //3) Set up an advertiser
    if (kProgrammaticDiscovery)
    {
        // Set it up programmatically
        self.advertiser = [[MCNearbyServiceAdvertiser alloc]
                           initWithPeer:self.peerId
                           discoveryInfo:nil
                           serviceType:kServiceType];
        self.advertiser.delegate = self;
        // Start advertising
        [self.advertiser startAdvertisingPeer];
    }
    else
    {
//        // Set it up using the convenience class
//        self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType
//                                                                        discoveryInfo:nil
//                                                                              session:self.session];
//        // Start advertising
//        [self.advertiserAssistant start];
    }
    
    
    //////////////////
    //CORE DATA///////
    //////////////////
    //Insert in Core Data every 2 secs
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:self
                                   selector:@selector(insertSomethingInCoreData)
                                   userInfo:nil
                                    repeats:YES];
    
    /////////////////////////////////
    // Start iBeacon advertising ////
    /////////////////////////////////
    NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
        [[BeaconAdvertisingService sharedInstance] startAdvertisingUUID:plasticOmiumUUID major:0 minor:0];

    
    return YES;
}



#pragma mark - MCNearbyServiceAdvertiserDelegate delegate methods
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    // Save the invitation handler for later use
    self.handler = invitationHandler;

    // Call the invitation handler
    self.handler(YES, self.session);
    
    [self.advertiser stopAdvertisingPeer];
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}



#pragma mark - MCSessionDelegate delegate methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
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
    // Get the data to be stored
    NSString *firstNameLastName = [NSString stringWithUTF8String:data.bytes];
    
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





- (void) insertSomethingInCoreData
{
    Event  * event1  = nil;
    Client * client1 = nil;
    
    event1 = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                           inManagedObjectContext:self.managedObjectContext];
    
    client1 = [NSEntityDescription insertNewObjectForEntityForName:@"Client"
                                            inManagedObjectContext:self.managedObjectContext];
    
    client1.firstName = @"Max";
    client1.lastName  = @"Bernard";
    
    event1.inOrOut = @0;
    event1.timestamp = [NSDate date];
    event1.client = client1;
    
    NSError* error0 = nil;
    [self.managedObjectContext save:&error0];
}









- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AppExposantGeoDetect" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AppExposantGeoDetect.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

//
//  AppDelegate.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconAdvertisingService.h"
#import "RootViewController.h"
#import "Event.h"
#import "Client.h"
#import "MPConnectivityHandler.h"
#warning to be removed
#import <MultipeerConnectivity/MultipeerConnectivity.h>

NSString *const letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@interface AppDelegate ()<UIAlertViewDelegate, UINavigationControllerDelegate>



#warning to be removed
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCPeerID *peerId;

@end

@implementation AppDelegate

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



-(void)applicationDidEnterBackground:(UIApplication *)application
{
    NSError* error0 = nil;
    [self.managedObjectContext save:&error0];
}  

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController * navVC = (UINavigationController*)self.window.rootViewController;
    
    navVC.delegate = self;
    
    #warning temporary timer
    
    #warning to be removed
    
    /////////////////////////////////
    // Start iBeacon advertising ////
    /////////////////////////////////
    NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
    [[BeaconAdvertisingService sharedInstance] startAdvertisingUUID:plasticOmiumUUID major:0 minor:0];
    
    
    //1) Set up a peer
    NSString *peerName = [[UIDevice currentDevice] name];
    self.peerId = [[MCPeerID alloc] initWithDisplayName:peerName];
    
    
    
    
    //2) Set up a session
    self.session = [[MCSession alloc] initWithPeer:self.peerId
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
    
//    [NSTimer scheduledTimerWithTimeInterval:4.0
//                                     target:self
//                                   selector:@selector(receiveFakeData1)
//                                   userInfo:nil
//                                    repeats:YES];
//    [NSTimer scheduledTimerWithTimeInterval:6.0
//                                     target:self
//                                   selector:@selector(receiveFakeData2)
//                                   userInfo:nil
//                                    repeats:YES];
//    [NSTimer scheduledTimerWithTimeInterval:8.0
//                                     target:self
//                                   selector:@selector(receiveFakeData3)
//                                   userInfo:nil
//                                    repeats:YES];
    
    return YES;
}


#warning to be removed
-(void)receiveFakeData1
{
    
    NSArray * dataFromNearByIphoneArray = @[@"Bernard", @"max@gmail.com", @"Wassa", @"Dev iOS", @1];
    NSData      *toSend = [NSKeyedArchiver archivedDataWithRootObject:dataFromNearByIphoneArray];
    [self.mpConnectHandler session:self.session didReceiveData:toSend fromPeer:self.peerId];

    

}
-(void)receiveFakeData2
{
    NSArray * dataFromNearByIphoneArray = @[@"Bernard", @"max@gmail.com", @"Wassa", @"Dev iOS", @0];
    NSData      *toSend = [NSKeyedArchiver archivedDataWithRootObject:dataFromNearByIphoneArray];
    [self.mpConnectHandler session:self.session didReceiveData:toSend fromPeer:self.peerId];

}
-(void)receiveFakeData3
{
    NSArray * dataFromNearByIphoneArray = @[@"Schaeffer", @"peter@gmail.com", @"Wassa", @"Dev iOS", @0];
    NSData      *toSend = [NSKeyedArchiver archivedDataWithRootObject:dataFromNearByIphoneArray];
    [self.mpConnectHandler session:self.session didReceiveData:toSend fromPeer:self.peerId];

}


//Smooth show/hide navBar
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL isSearchVc = [viewController isKindOfClass:RootViewController.class];
    
    [viewController.navigationController setNavigationBarHidden:isSearchVc animated:animated];
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




////

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

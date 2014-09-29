//
//  AppDelegate.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

// The service type identifier
extern NSString * const kServiceType;
// The notification string to be used for data receipts
extern NSString *const DataReceivedNotification;
// A flag to use programmatic APIs for the discovery phase
extern BOOL const kProgrammaticDiscovery;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) insertEventInCoreDataWithFirstName:(NSString*)firstName LastName:(NSString*)lastname andInOrOut:(NSNumber*)inOrOut;

@end

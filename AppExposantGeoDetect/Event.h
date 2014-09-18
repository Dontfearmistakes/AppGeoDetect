//
//  Event.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 18/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * inOrOut;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Client *client;

@end

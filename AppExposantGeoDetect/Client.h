//
//  Client.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 18/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Client : NSManagedObject


@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * societe;
@property (nonatomic, retain) NSString * titre;
@property (nonatomic, retain) NSSet *events;
@end

@interface Client (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end

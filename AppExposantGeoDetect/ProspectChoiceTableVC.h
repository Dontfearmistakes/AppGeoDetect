//
//  ProspectChoiceTableVC.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 03/10/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProspectDisplayVC;

@protocol ProspectChoiceDelegate <NSObject>

@required

-(void)selectedProspect:(NSString *)prospectName;

@end


@interface ProspectChoiceTableVC : UITableViewController

@property (nonatomic, strong) NSMutableArray *clientNames;
@property (nonatomic, strong) NSMutableArray *clients;
@property (nonatomic, weak) id<ProspectChoiceDelegate> delegate;
@property (nonatomic, strong) ProspectDisplayVC *prospectDisplayVC;


@end

//
//  DetailViewController.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

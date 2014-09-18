//
//  loginVC.h
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTxtfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTxtfield;



- (IBAction)clickOnRegisterButton:(UIButton *)sender;


@end
//
//  loginVC.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "LoginVC.h"
#import "LoggedVC.h"
#import <GSKeychain/GSKeychain.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"
#import "BeaconMonitoringService.h"

@interface LoginVC ()

@end

@implementation LoginVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.firstNameTxtfield.delegate = self;
    self.lastNameTxtfield.delegate = self;
    
    
    //Dismiss keyboard if touch outside of Textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(didTapOnTableView:)];
    
    [self.view addGestureRecognizer:tap];
    
}

-(void) didTapOnTableView:(id) sender
{
    
    if ([self.firstNameTxtfield isFirstResponder])
        [self.firstNameTxtfield resignFirstResponder];
    
    if ([self.lastNameTxtfield isFirstResponder])
        [self.lastNameTxtfield resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action Method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
- (IBAction)clickOnRegisterButton:(UIButton *)sender
{
    // SI AUCUN CHAMPS N'EST LAISSE VIDE PAR LE USER
    if (![self.firstNameTxtfield.text isEqualToString:@""]
        &&
        ![self.lastNameTxtfield.text  isEqualToString:@""])
    {
        // 1 : REMPLIS LE KEYCHAIN
        [[GSKeychain systemKeychain] setSecret:self.firstNameTxtfield.text forKey:@"firstName"];
        [[GSKeychain systemKeychain] setSecret:self.lastNameTxtfield.text  forKey:@"lastName"];
        
        
        // 2 : CONNECTION AU iBEACON
            #warning switch iBeacon/iPad
            NSUUID *plasticOmiumUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
            
            [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:plasticOmiumUUID
                                                                              major:0
                                                                              minor:0
                                                                         identifier:@"com.razeware.waitlist"
                                                                            onEntry:YES
                                                                             onExit:YES];
            
            //    NSUUID *ibeaconUUID = [[NSUUID alloc] initWithUUIDString:@"85FC11DD-4CCA-4B27-AFB3-876854BB5C3B"];
            //    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:ibeaconUUID
            //                                                                          major:523
            //                                                                          minor:220
            //                                                                     identifier:@"com.razeware.waitlist"
            //                                                                        onEntry:YES
            //                                                                         onExit:YES];
        
        
        
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }

}




@end

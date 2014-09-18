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
    // Store firstName/lastName
    [[GSKeychain systemKeychain] setSecret:self.firstNameTxtfield.text forKey:@"firstName"];
    [[GSKeychain systemKeychain] setSecret:self.lastNameTxtfield.text  forKey:@"lastName"];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}
@end

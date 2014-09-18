//
//  LoggedVC.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 17/09/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "LoggedVC.h"
#import <GSKeychain/GSKeychain.h>

@interface LoggedVC ()

@end

@implementation LoggedVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



-(void)viewWillAppear:(BOOL)animated
{
    // Is there a firstname/lastname in the keychain ?
    NSString *firstnameInKC = [[GSKeychain systemKeychain] secretForKey:@"firstName"];
    
    // If not, ask first/lastname
    if (firstnameInKC == nil)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        

        [self.navigationController presentViewController:loginVC animated:NO completion:nil];
        
    }
    // Si oui
    else
    {
        self.firstNameLastNameLabel.text = [NSString stringWithFormat:@"%@ %@", [[GSKeychain systemKeychain] secretForKey:@"firstName"], [[GSKeychain systemKeychain] secretForKey:@"lastName"]];
    }

}



- (IBAction)clickOnDisconnectButton:(id)sender
{
    [[GSKeychain systemKeychain] removeAllSecrets];
}

@end

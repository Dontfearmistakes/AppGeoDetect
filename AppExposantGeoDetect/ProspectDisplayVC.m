//
//  ProspectDisplayVC.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 03/10/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "ProspectDisplayVC.h"

@interface ProspectDisplayVC ()

@end

@implementation ProspectDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLabels)
                                                 name:@"didSelectProspect"
                                               object:nil];
}

-(void)updateLabels
{
    self.prospectNameLabel.text    = [NSString stringWithFormat:@"%@", self.client.lastName];
    self.prospectSocieteLabel.text = [NSString stringWithFormat:@"%@", self.client.societe];
    self.prospectTitreLabel.text   = [NSString stringWithFormat:@"%@", self.client.titre];
    self.prospectEmailLabel.text   = [NSString stringWithFormat:@"%@", self.client.email];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = @"test";
    
    return cell;
}


#pragma mark - ColorPickerDelegate method
-(void)selectedProspect:(NSString *)prospectName
{
    self.prospectNameLabel.text = prospectName;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showPopOver"])
    {
        // Get reference to the destination view controller
        ProspectChoiceTableVC *prospectChoiceTblVC = [segue destinationViewController];
                               prospectChoiceTblVC.delegate = self;
                               prospectChoiceTblVC.prospectDisplayVC = self;
    }
}




@end

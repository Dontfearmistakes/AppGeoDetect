//
//  ProspectChoiceTableVC.m
//  AppExposantGeoDetect
//
//  Created by Maxime BERNARD on 03/10/2014.
//  Copyright (c) 2014 Wassa. All rights reserved.
//

#import "AppDelegate.h"
#import "ProspectChoiceTableVC.h"
#import "ProspectDisplayVC.h"
#import "Client.h"


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
@interface ProspectChoiceTableVC ()

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSMutableArray         * clientsNamesFirstLetters ;
@property (assign)            BOOL                     thisFirstLetterAlreadyExists ;
@property(readwrite, copy, nonatomic) NSArray *tableData;

@end

@implementation ProspectChoiceTableVC



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

//1. Supply a localized table index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    //Initialize the array
    self.clients                    = [NSMutableArray array];
    self.clientNames                = [NSMutableArray array];
    self.clientsNamesFirstLetters   = [NSMutableArray array];
    
    //Make row selections persist.
    self.clearsSelectionOnViewWillAppear = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSFetchRequest *request                 =   [NSFetchRequest   fetchRequestWithEntityName:@"Client"];
                    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
    
    NSError *error = nil;
    self.clients   = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    for (Client *client in self.clients)
    {
        // Je rempis un tableau avec tous les noms de famille
        [self.clientNames addObject: client.lastName];
        
        // Je choppe la 1ere lettres du nom de famille qu'on vient d'ajouter pour voir si on l'avait déjà
        NSString * prospectNameFirstLetter = [client.lastName substringToIndex:1];
        
        // Est ce qu'on l'avait déjà parmi tous les firstLetters ajoutées so far ?
        for (NSString * firstLetter in self.clientsNamesFirstLetters)
        {
            if ([firstLetter isEqualToString:prospectNameFirstLetter])
            {
                self.thisFirstLetterAlreadyExists = YES;
            }
        }
        
        //Si non alors on l'ajoute
        if (self.thisFirstLetterAlreadyExists == NO)
        {
            [self.clientsNamesFirstLetters addObject:prospectNameFirstLetter];
        }
    }
    
    [self.tableView reloadData];
}


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.clientsNamesFirstLetters count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.clients count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [(Client *)[self.clients objectAtIndex:indexPath.row] lastName]];
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView  *view  = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string =[self.clientsNamesFirstLetters objectAtIndex:section];
    [label setText:string];
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Client *selectedClient = (Client *)[self.clients objectAtIndex:indexPath.row];
    
    
    //Notify the delegate if it exists.
    if (self.delegate != nil) {
        
         self.prospectDisplayVC.client = selectedClient;
        [self.delegate selectedProspect:selectedClient.lastName];
        

        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectProspect" object:self userInfo:nil];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end

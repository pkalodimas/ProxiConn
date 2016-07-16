//
//  FirstViewController.m
//  CarGps
//
//  Created by Panos Kalodimas on 10/22/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "MembersViewController.h"

@interface MembersViewController ()

@end

@implementation MembersViewController

@synthesize manager;
@synthesize commandRequest;
@synthesize neighboursLoading;
@synthesize directionImages;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.manager delegateAdd:self];
    self.commandRequest = nil;
    [self.neighboursLoading setHidden:YES];
    self.directionImages = [NSArray arrayWithObjects:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MEMBERSVIEW_IMAGE_NORTH ofType:MEMBERSVIEW_IMAGE_TYPE]],
                                                    [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MEMBERSVIEW_IMAGE_SOUTH ofType:MEMBERSVIEW_IMAGE_TYPE]],
                                                    [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MEMBERSVIEW_IMAGE_WEST ofType:MEMBERSVIEW_IMAGE_TYPE]],
                                                    [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MEMBERSVIEW_IMAGE_EAST ofType:MEMBERSVIEW_IMAGE_TYPE]],
                            nil];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}


-(void)AppManagerNeighboursUpdated:(id)appmanager{
    
    [self.tableView reloadData];
}

-(void)serverCommandHanler:(id)command{
    
    if( !command ) return;
    if( [self.commandRequest isEqual:command] ){
        
        [self.manager serverErrorHanler:self.commandRequest.error  withAlert:YES];
        self.commandRequest = NULL;
        [self.neighboursLoading stopAnimating];
        self.neighboursLoading.hidden = YES;
    }
}

-(IBAction)updateButtonPushed:(id)sender{
    
    if( self.manager.netStatus && self.manager.logStatus == LOG_STATE_LOGIN ){
        
        if( self.commandRequest ) return;
        
        self.commandRequest = [self.manager userNeighboursUpdate];
        if( self.commandRequest ){
            [self.commandRequest addDelegate:self];
            self.neighboursLoading.hidden = NO;
            [self.neighboursLoading startAnimating];
        }
        else [self infoAlert:@"Neighbors update" withMessage:@"Neighbors update command denied. Please check services"];
    }
    else if( !self.manager.netStatus ) [self noNetworkAlert];
    else [self noLoginAlert];
}

//---------------------------------------------------------------------------
//---------------------------- UITableViewDataSource ------------------------
//---------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.manager.neighbours.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CarGpsUser *user = [self.manager.neighbours objectAtIndex:indexPath.row];
    if( !user ) return nil;
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"memberCell"];
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2fm", user.distance];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if( user.direction != DIRECTION_ERROR ) [cell.imageView setImage:[self.directionImages objectAtIndex:user.direction-1]];
    
    return cell;
}

//---------------------------------------------------------------------------
//---------------------------- UITableViewDelegate --------------------------
//---------------------------------------------------------------------------

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if( [segue.identifier isEqualToString:@"userInfoSegue"]){
        
        NSIndexPath *index = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        InfoViewController *ivc = segue.destinationViewController;
        ivc.manager = self.manager;
        ivc.user = [self.manager.neighbours objectAtIndex:index.row];
    }
}


@end

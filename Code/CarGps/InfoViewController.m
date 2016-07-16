//
//  InfoViewController.m
//  CarGps
//
//  Created by Panos Kalodimas on 10/29/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize usernameCell;
@synthesize nameCell;
@synthesize facebookCell;
@synthesize distanceCell;
@synthesize directionCell;
@synthesize latitudeCell;
@synthesize longitudeCell;
@synthesize commandRequest;
@synthesize manager;
@synthesize user;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.commandRequest = NULL;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.usernameCell.detailTextLabel.text = self.user.username;
    self.nameCell.detailTextLabel.text = [self.user.info valueForKey:NAME];
    self.facebookCell.detailTextLabel.text = [self.user.info valueForKey:FACEBOOK];
    self.distanceCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", self.user.distance];
    self.directionCell.detailTextLabel.text = [self directionText:self.user.direction];
    self.latitudeCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.13f", self.user.coordinate.latitude];
    self.longitudeCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.13f", self.user.coordinate.longitude];
    
    if( !self.usernameCell.detailTextLabel.text ) self.usernameCell.detailTextLabel.text = MEMBERSVIEW_NOT_AVAILABLE;
    if( !self.nameCell.detailTextLabel.text ) self.nameCell.detailTextLabel.text = ( self.commandRequest ) ? MEMBERSVIEW_PENDING_SERVER : MEMBERSVIEW_NOT_AVAILABLE;
    if( !self.facebookCell.detailTextLabel.text ) self.facebookCell.detailTextLabel.text = ( self.commandRequest ) ? MEMBERSVIEW_PENDING_SERVER : MEMBERSVIEW_NOT_AVAILABLE;
    if( !self.distanceCell.detailTextLabel.text ) self.distanceCell.detailTextLabel.text = MEMBERSVIEW_NOT_AVAILABLE;
    if( !self.directionCell.detailTextLabel.text ) self.directionCell.detailTextLabel.text = MEMBERSVIEW_NOT_AVAILABLE;
    if( !self.latitudeCell.detailTextLabel.text ) self.latitudeCell.detailTextLabel.text = MEMBERSVIEW_NOT_AVAILABLE;
    if( !self.longitudeCell.detailTextLabel.text ) self.longitudeCell.detailTextLabel.text = MEMBERSVIEW_NOT_AVAILABLE;
    
    if( !self.user.info && !self.commandRequest ) {
        
        self.commandRequest = [self.manager userInfo:self.user];
        [self.commandRequest addDelegate:self];
    }
}

-(NSString*)directionText:(LocationDirection)direction{
    
    switch (direction) {
        case DIRECTION_NORTH: return MEMBERSVIEW_DIRECTION_NORTH;
        case DIRECTION_SOUTH: return MEMBERSVIEW_DIRECTION_SOUTH;
        case DIRECTION_WEST: return MEMBERSVIEW_DIRECTION_WEST;
        case DIRECTION_EAST: return MEMBERSVIEW_DIRECTION_EAST;
        default: return MEMBERSVIEW_NOT_AVAILABLE;
    }
}

-(IBAction)backButtonPushed:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    if( self.commandRequest ) [self.manager cancelCommand:self.commandRequest sender:self];
}

-(void)serverCommandHanler:(id)command{
    
    if( !command ) return;
    if( [self.commandRequest isEqual:command] ){
        
        if( self.commandRequest.error == NO_ERROR ){
            
            [self.user infoFromDictionary:self.commandRequest.response];
            self.commandRequest = NULL;
            [self viewWillAppear:YES];
        }
        else [self.manager serverErrorHanler:self.commandRequest.error withAlert:YES];
    }
}


@end

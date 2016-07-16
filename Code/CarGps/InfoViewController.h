//
//  InfoViewController.h
//  CarGps
//
//  Created by Panos Kalodimas on 10/29/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarGpsAppManager.h"

@interface InfoViewController : UITableViewController <CarGpsServerCommandDelegate> {
    
    UITableViewCell *usernameCell;
    UITableViewCell *nameCell;
    UITableViewCell *facebookCell;
    UITableViewCell *distanceCell;
    UITableViewCell *directionCell;
    UITableViewCell *latitudeCell;
    UITableViewCell *longitudeCell;
    
    CarGpsServerCommand *commandRequest;
    CarGpsAppManager *manager;
    CarGpsUser *user;
}

@property (retain, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *facebookCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *distanceCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *directionCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *latitudeCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *longitudeCell;
@property (retain, nonatomic) CarGpsServerCommand *commandRequest;
@property (retain, nonatomic) CarGpsAppManager *manager;
@property (retain, nonatomic) CarGpsUser *user;

-(IBAction)backButtonPushed:(id)sender;
-(NSString*)directionText:(LocationDirection)direction;

@end

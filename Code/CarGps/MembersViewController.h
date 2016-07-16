//
//  FirstViewController.h
//  CarGps
//
//  Created by Panos Kalodimas on 10/22/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarGpsAppManager.h"
#import "InfoViewController.h"

@interface MembersViewController : UITableViewController <CarGpsAppManagerDelegate, CarGpsServerCommandDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    UIActivityIndicatorView *neighboursLoading;
    CarGpsServerCommand *commandRequest;
    CarGpsAppManager *manager;
    NSArray *directionImages;
}

@property (retain,nonatomic) IBOutlet UIActivityIndicatorView *neighboursLoading;
@property (retain,nonatomic) CarGpsServerCommand *commandRequest;
@property (retain,nonatomic) CarGpsAppManager *manager;
@property (retain,nonatomic) NSArray *directionImages;

-(IBAction)updateButtonPushed:(id)sender;

@end

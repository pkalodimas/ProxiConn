//
//  SettingsContainerViewController.m
//  CarGPS
//
//  Created by Panos Kalodimas on 10/10/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "SettingsContainerViewController.h"

@interface SettingsContainerViewController ()

@end

@implementation SettingsContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ( [segue.identifier isEqualToString:@"SettingsSegue"]) {
        
        [(SettingsViewController*)segue.destinationViewController setManager:[(MainViewController*)self.parentViewController manager]];
    }
}


@end

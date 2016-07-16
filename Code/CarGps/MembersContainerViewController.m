//
//  MembersContainerViewController.m
//  CarGps
//
//  Created by Panos Kalodimas on 11/11/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "MembersContainerViewController.h"

@interface MembersContainerViewController ()

@end

@implementation MembersContainerViewController

@synthesize updateButton;
@synthesize updateIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
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

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ( [segue.identifier isEqualToString:@"MembersContainerSegue"]) {
        
        MembersViewController *dvc = segue.destinationViewController;
        
        [dvc setManager:[(MainViewController*)self.parentViewController manager]];
        dvc.neighboursLoading = self.updateIndicator;
        [self.updateButton setTarget:dvc];
        [self.updateButton setAction:@selector(updateButtonPushed:)];
    }
}




@end

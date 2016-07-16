//
//  MainViewController.m
//  CarGPS
//
//  Created by Panos Kalodimas on 9/14/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "MainViewController.h"

#import "AppDefinitions.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize manager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.manager = [[CarGpsAppManager alloc] initFromSettings];
    [self.manager startServices];
        
    self.selectedIndex = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
















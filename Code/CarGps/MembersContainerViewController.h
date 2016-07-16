//
//  MembersContainerViewController.h
//  CarGps
//
//  Created by Panos Kalodimas on 11/11/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"
#import "MembersViewController.h"

@interface MembersContainerViewController : UIViewController{
    
    UIBarButtonItem *updateButton;
    UIActivityIndicatorView *updateIndicator;
}

@property (retain,nonatomic) IBOutlet UIBarButtonItem *updateButton;
@property (retain,nonatomic) IBOutlet UIActivityIndicatorView *updateIndicator;

@end

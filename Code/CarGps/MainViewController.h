//
//  MainViewController.h
//  CarGPS
//
//  Created by Panos Kalodimas on 9/14/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "CarGpsAppManager.h"
#import "SettingsViewController.h"

@interface MainViewController : UITabBarController{

    CarGpsAppManager *manager;
}

@property (retain,nonatomic) CarGpsAppManager *manager;




@end

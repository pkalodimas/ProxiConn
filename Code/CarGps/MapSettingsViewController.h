//
//  MapSettingsViewController.h
//  CarGps
//
//  Created by Panos Kalodimas on 11/3/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDefinitions.h"
#import "CarGpsSettings.h"

@protocol MapSettingsDelegate @required

-(void)mapSettingsValueChanged:(id)command;

@end

@interface MapSettingsViewController : UIViewController{
    
    UISegmentedControl *mapTypeSetting;
    UISegmentedControl *mapUserFollowSetting;
    UISegmentedControl *mapRangeRetainSetting;
    id<MapSettingsDelegate> delegate;
}

@property (retain, nonatomic) IBOutlet UISegmentedControl *mapTypeSetting;
@property (retain, nonatomic) IBOutlet UISegmentedControl *mapUserFollowSetting;
@property (retain, nonatomic) IBOutlet UISegmentedControl *mapRangeRetainSetting;
@property (retain, nonatomic) id<MapSettingsDelegate> delegate;

-(void)presentSettings;
-(IBAction)settingsValueChanged:(id)sender;

@end

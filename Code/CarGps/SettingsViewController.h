//
//  SettingsViewController.h
//  CarGPS
//
//  Created by Panos Kalodimas on 9/21/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "AppDefinitions.h"
#import "CarGpsAppManager.h"
#import "CarGpsAlerts.h"
#import "AccountViewController.h"
#import "StationViewController.h"

@interface SettingsViewController : UITableViewController <CarGpsAppManagerDelegate, UITextFieldDelegate, UIAlertViewDelegate, CarGpsServerCommandDelegate> {
    
    //Status settings
    UILabel *netStatusLabel;
    UILabel *gpsStausLabel;
    UILabel *serverStatusLabel;
    UILabel *latitudeStatusLabel;
    UILabel *longitudeStatusLabel;
    //user settings
    UISwitch *userRememberSwitch;
    UISwitch *autoLoginSwitch;
    UILabel *userSettingLabel;
    UIActivityIndicatorView *loadingView;
    UIButton *logButton;
    UIButton *accountButton;
    //server settings
    UILabel *rangeSettingLabel;
    UILabel *neighbourSettingLabel;
    UILabel *sessionSettingLabel;
    UISlider *distanceSlider;
    UISegmentedControl *rangeMultiplier;
    UISlider *neighbourSlider;
    UISlider *sessionSlider;
    UITextField *serverTextField;
    UITextField *serverUrlTextField;
    //gps settings
    UILabel *accuracyLabel;
    UILabel *distanceFilterLabel;
    UISlider *accuracySlider;
    UISlider *distanceFilterSlider;
    UISegmentedControl *activitySegments;
    UILabel *stationLabel;
    CLLocationCoordinate2D stationCoordinates;
    
    CarGpsServerCommand *commandRequest;
    CarGpsAppManager *manager;
}
@property (retain, nonatomic) IBOutlet UILabel *netStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *gpsStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *serverStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *latitudeStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *longitudeStatusLabel;

@property (retain, nonatomic) IBOutlet UISwitch *userRememberSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *autoLoginSwitch;
@property (retain, nonatomic) IBOutlet UILabel *userSettingLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (retain, nonatomic) IBOutlet UIButton *logButton;
@property (retain, nonatomic) IBOutlet UIButton *accountButton;

@property (retain, nonatomic) IBOutlet UILabel *rangeSettingLabel;
@property (retain, nonatomic) IBOutlet UILabel *neighbourSettingLabel;
@property (retain, nonatomic) IBOutlet UILabel *sessionSettingLabel;
@property (retain, nonatomic) IBOutlet UISlider *rangeSlider;
@property (retain, nonatomic) IBOutlet UISegmentedControl *rangeMultiplier;
@property (retain, nonatomic) IBOutlet UISlider *neighbourSlider;
@property (retain, nonatomic) IBOutlet UISlider *sessionSlider;
@property (retain, nonatomic) IBOutlet UITextField *serverTextField;
@property (retain, nonatomic) IBOutlet UITextField *serverUrlTextField;

@property (retain, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (retain, nonatomic) IBOutlet UILabel *distanceFilterLabel;
@property (retain, nonatomic) IBOutlet UISlider *accuracySlider;
@property (retain, nonatomic) IBOutlet UISlider *distanceFilterSlider;
@property (retain, nonatomic) IBOutlet UISegmentedControl *activitySegments;
@property (retain, nonatomic) IBOutlet UILabel *stationLabel;
@property (assign, nonatomic) CLLocationCoordinate2D stationCoordinates;

@property (retain, nonatomic) CarGpsServerCommand *commandRequest;
@property (retain, nonatomic) CarGpsAppManager *manager;

-(void)settingsPresent;

-(IBAction)logButton:(id)sender;
-(IBAction)accountButton:(id)sender;
-(IBAction)settingValueChanged:(id)sender;
-(IBAction)saveSettingsButton:(id)sender;

@end

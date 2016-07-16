//
//  SettingsViewController.m
//  CarGPS
//
//  Created by Panos Kalodimas on 9/21/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize netStatusLabel;
@synthesize gpsStatusLabel;
@synthesize serverStatusLabel;
@synthesize latitudeStatusLabel;
@synthesize longitudeStatusLabel;

@synthesize userRememberSwitch;
@synthesize autoLoginSwitch;
@synthesize userSettingLabel;
@synthesize loadingView;
@synthesize logButton;
@synthesize accountButton;

@synthesize rangeSettingLabel;
@synthesize neighbourSettingLabel;
@synthesize sessionSettingLabel;
@synthesize rangeSlider;
@synthesize rangeMultiplier;
@synthesize neighbourSlider;
@synthesize sessionSlider;
@synthesize serverTextField;
@synthesize serverUrlTextField;

@synthesize accuracyLabel;
@synthesize distanceFilterLabel;
@synthesize accuracySlider;
@synthesize distanceFilterSlider;
@synthesize activitySegments;
@synthesize stationLabel;
@synthesize stationCoordinates;

@synthesize commandRequest;
@synthesize manager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.manager delegateAdd:self];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self settingsPresent];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)settingsPresent{
    
    NSMutableDictionary *settings = [self loadSettings];
    
    [self AppManagerNetworkStatusChanged:self.manager];
    [self AppManagerGpsStatusChanged:self.manager];
    [self AppManagerServerStatusChanged:self.manager];
    
    //User Settings
    if( [[self getSetting:settings name:SETTINGS_REMEMBER_LAST_USER] boolValue] ) self.userRememberSwitch.on = YES;
    else self.userRememberSwitch.on = NO;
    
    if( [[self getSetting:settings name:SETTINGS_AUTOLOGIN] boolValue] ) self.autoLoginSwitch.on = YES;
    else self.autoLoginSwitch.on = NO;
    
    if( self.autoLoginSwitch.on ) {
        self.userRememberSwitch.on = YES;
        self.userRememberSwitch.enabled = NO;
    }
    else self.userRememberSwitch.enabled = YES;
    
    [self AppManagerLogStatusChanged:self.manager];

    //Server Settings
    self.sessionSlider.value = [[self getSetting:settings name:SETTINGS_SESSION_UPDATE_TIME] integerValue];
    [self settingValueChanged:self.sessionSlider];

    int range = [[self getSetting:settings name:SETTINGS_NEIGHBOUR_RANGE] integerValue];
    if( range == 0 ){
        self.rangeMultiplier.selectedSegmentIndex = 3;
        self.rangeSlider.value = 9;
    }
    else{
        self.rangeMultiplier.selectedSegmentIndex = (int) floor(log10((double)range)) - 1;
        self.rangeSlider.value = (int) range / pow(10, self.rangeMultiplier.selectedSegmentIndex+1);
    }
    [self settingValueChanged:self.rangeMultiplier];
    
    self.neighbourSlider.value = [[self getSetting:settings name:SETTINGS_NEIGHBOUR_UPDATE_TIME] integerValue];
    [self settingValueChanged:self.neighbourSlider];
    
    self.serverTextField.text = [self getSetting:settings name:SETTINGS_SERVER];
    self.serverUrlTextField.text = [self getSetting:settings name:SETTINGS_SERVER_URL];
    
    //GPS Settings
    self.accuracySlider.value = [[self getSetting:settings name:SETTINGS_GPS_ACCURACY] integerValue] + 1;
    [self settingValueChanged:self.accuracySlider];
    
    self.distanceFilterSlider.value = [[self getSetting:settings name:SETTINGS_GPS_DISTANCE_FILTER] integerValue];
    [self settingValueChanged:self.distanceFilterSlider];
    
    self.activitySegments.selectedSegmentIndex = [[self getSetting:settings name:SETTINGS_GPS_ACTIVITY] integerValue] - 2;
    
    self.stationLabel.text = ( [[self getSetting:settings name:SETTINGS_STATION] boolValue] ) ? SETTINGSVIEW_STATION_ON : SETTINGSVIEW_STATION_OFF;
}


//--------------------------------------------------------------------------------------
//-------------------------- Button & Interface Methods --------------------------------
//--------------------------------------------------------------------------------------

-(IBAction)settingValueChanged:(id)sender{
    
    //autoLogin
    if( [[sender restorationIdentifier] isEqualToString:@"AutoLogin"] ){
        
        if( self.autoLoginSwitch.on ) {
            
            self.userRememberSwitch.on = YES;
            self.userRememberSwitch.enabled = NO;
            [self saveSettingsButton:self.userRememberSwitch];
        }
        else self.userRememberSwitch.enabled = YES;
        
        [self saveSettingsButton:self.autoLoginSwitch];
        [self.manager setAutoLoginFlag:self.autoLoginSwitch.on];
    }
    //Remember Last User
    else if( [[sender restorationIdentifier] isEqualToString:@"RememberLastUser"] ) {
        
        [self saveSettingsButton:self.userRememberSwitch];
    }
    //Neighbours Radius
    else if( [[sender restorationIdentifier] isEqualToString:@"NeighboursRange"] ) {
        
        if( self.rangeMultiplier.selectedSegmentIndex < 3 ) self.rangeSettingLabel.text = [NSString stringWithFormat:@"Neighbors Range: %dx%dm", (int) self.rangeSlider.value, (int)pow(10, self.rangeMultiplier.selectedSegmentIndex+1)];
    }
    //Radius multiplier
    else if( [[sender restorationIdentifier] isEqualToString:@"RangeMultiplier"] ) {
        
        if( self.rangeMultiplier.selectedSegmentIndex < 3 ) self.rangeSettingLabel.text = [NSString stringWithFormat:@"Neighbors Range: %dx%dm", (int) self.rangeSlider.value, (int)pow(10, self.rangeMultiplier.selectedSegmentIndex+1)];
        else self.rangeSettingLabel.text = @"Neighbors Range: ALL";
    }
    //Neighbours update time
    else if( [[sender restorationIdentifier] isEqualToString:@"NeighboursUpdateTime"] ) {

        self.neighbourSettingLabel.text = [NSString stringWithFormat:@"Neighbors Update Time: %d sec", (int) self.neighbourSlider.value];
        if( (int)self.sessionSlider.value > (int)self.neighbourSlider.value ) self.sessionSlider.value = ( (int) self.neighbourSlider.value > 0 ) ? (int) self.neighbourSlider.value : 1;
        self.sessionSlider.maximumValue = ( (int) self.neighbourSlider.value > 0 ) ? (int) self.neighbourSlider.value : 1;
        [self settingValueChanged:self.sessionSlider];
    }
    //Session update time
    else if( [[sender restorationIdentifier] isEqualToString:@"SessionUpdateTime"] ) {
     
        self.sessionSettingLabel.text = [NSString stringWithFormat:@"Session Update Time: %d sec", (int) self.sessionSlider.value];
    }
    //Accurancy
    else if( [[sender restorationIdentifier] isEqualToString:@"Accuracy"] ) {
        
        if( (int)self.accuracySlider.value == -1 ) self.accuracyLabel.text = [NSString stringWithFormat:@"Accuracy : Best for Navigation"];
        else if( (int)self.accuracySlider.value == 0 ) self.accuracyLabel.text = [NSString stringWithFormat:@"Accuracy : Best"];
        else self.accuracyLabel.text = [NSString stringWithFormat:@"Accuracy : %dm", (int) self.accuracySlider.value];
    }
    //Distance filter
    else if( [[sender restorationIdentifier] isEqualToString:@"DistanceFilter"] ) {
        
        self.distanceFilterLabel.text = [NSString stringWithFormat:@"Distance Filter : %dm", (int) self.distanceFilterSlider.value];
    }
}

-(IBAction)saveSettingsButton:(id)sender{

    NSMutableDictionary *settings = [self loadSettings];
    
    //Server settings
    if( [[sender restorationIdentifier] isEqualToString:@"SaveServerSettings"] ){
        
        if( self.rangeMultiplier.selectedSegmentIndex == 3 )[self editSetting:settings name:SETTINGS_NEIGHBOUR_RANGE value:[NSNumber numberWithInt:0] save:NO];
        else [self editSetting:settings name:SETTINGS_NEIGHBOUR_RANGE value:[NSNumber numberWithInt:(self.rangeSlider.value*pow(10,self.rangeMultiplier.selectedSegmentIndex+1))] save:NO];
        [self editSetting:settings name:SETTINGS_NEIGHBOUR_UPDATE_TIME value:[NSNumber numberWithInt:self.neighbourSlider.value] save:NO];
        [self editSetting:settings name:SETTINGS_SESSION_UPDATE_TIME value:[NSNumber numberWithInt:self.sessionSlider.value] save:NO];
        [self editSetting:settings name:SETTINGS_SERVER_URL value:self.serverUrlTextField.text save:NO];
        [self editSetting:settings name:SETTINGS_SERVER value:self.serverTextField.text save:NO];
        if( [self saveSettings:settings] ){
            
            [self.manager restartClientConnection];
            [self infoAlert:@"Appling Settings" withMessage:@"Server client services restarted"];
        }
        else [self infoAlert:@"Error" withMessage:@"Save settings failed"];
    }
    //Gps Settings
    else if( [[sender restorationIdentifier] isEqualToString:@"SaveGpsSettings"] ){
        
        [self editSetting:settings name:SETTINGS_GPS_ACCURACY value:[NSNumber numberWithInt:(self.accuracySlider.value-1)] save:NO];
        [self editSetting:settings name:SETTINGS_GPS_DISTANCE_FILTER value:[NSNumber numberWithInt:(self.distanceFilterSlider.value)] save:NO];
        [self editSetting:settings name:SETTINGS_GPS_ACTIVITY value:[NSNumber numberWithInt:(self.activitySegments.selectedSegmentIndex+2)] save:NO];

        if( [self saveSettings:settings] ) {
            
            [self.manager restartLocationServices];
            [self infoAlert:@"Appling Settings" withMessage:@"Gps services restarted"];
        }
        else [self infoAlert:@"Error" withMessage:@"Save settings failed"];
    }
    //Remember Last user
    else if( [[sender restorationIdentifier] isEqualToString:@"RememberLastUser"] ){
        
        if( [self editSetting:settings name:SETTINGS_REMEMBER_LAST_USER value:[NSNumber numberWithBool:self.userRememberSwitch.on] save:YES] ){
        
            if( self.userRememberSwitch.on && self.manager.logStatus == LOG_STATE_LOGIN ) [self saveLastUser:self.manager.user toSettings:settings];
            else if( !self.userRememberSwitch.on ) {
            
                [self removeLastUser:nil];
                if( self.manager.logStatus != LOG_STATE_LOGIN ) self.manager.user.password = @"";
            }
        }
        else [self infoAlert:@"Error" withMessage:@"Save settings failed"];
    }
    //Autologin
    else if( [[sender restorationIdentifier] isEqualToString:@"AutoLogin"] ){

        if( ![self editSetting:settings name:SETTINGS_AUTOLOGIN value:[NSNumber numberWithBool:self.autoLoginSwitch.on] save:YES] ) [self infoAlert:@"Error" withMessage:@"Save settings failed"];
    }
    //Default settings
    else if( [[sender restorationIdentifier] isEqualToString:@"DefaultSettings"] ){
        
        settings = [self defaultSettings];
        if( [self saveSettings:settings] ){
        
            [self.manager restartServices];
            [self settingsPresent];
            [self infoAlert:@"Restoring Settings" withMessage:@"Server clients & GPS services restarted "];
        }
        else [self infoAlert:@"Error" withMessage:@"Save settings failed"];
    }
}

-(IBAction)logButton:(id)sender{
    
    NSString *buttonTitle = [[sender titleLabel] text];
    
    if ( [buttonTitle isEqualToString:SETTINGSVIEW_LOG_BUTTON_LOGIN] ) {
        
        [self.manager setAutoLoginFlag:self.autoLoginSwitch.on];
        if( self.manager.gpsStatus && self.manager.netStatus ) [self loginAlert:self withUser:self.manager.user];
        else if( !self.manager.netStatus ) [self noNetworkAlert];
        else [self noGPSAlert];
    }
    else if( [buttonTitle isEqualToString:SETTINGSVIEW_LOG_BUTTON_CANCEL] ){
        
        [self.manager setAutoLoginFlag:NO];
        [self.manager cancelCommand:[self.manager getCommand:SERVER_LOGIN] sender:self];
    }
    else{
        
        [self.manager setAutoLoginFlag:NO];
        [self.manager userLogout];
    }
}

-(IBAction)accountButton:(id)sender{
        
    if( self.manager.netStatus ) [self performSegueWithIdentifier:@"AccountSegue" sender:self];
    else [self noNetworkAlert];
}


//--------------------------------------------------------------------------------------
//-------------------------- Delegates Methods -----------------------------------------
//--------------------------------------------------------------------------------------

//Delegate from AppManager
-(void)AppManagerLogStatusChanged:(id)appmanager{
    
    if ( self.manager.logStatus == LOG_STATE_LOGIN ) {
        
        self.userSettingLabel.text = self.manager.user.username;
        [self.logButton setTitle:SETTINGSVIEW_LOG_BUTTON_LOGOUT forState:UIControlStateNormal];
        [self.logButton setTitle:SETTINGSVIEW_LOG_BUTTON_LOGOUT forState:UIControlStateSelected];
        [self.accountButton setTitle:SETTINGSVIEW_ACCOUNT_BUTTON_EDIT_USER forState:UIControlStateNormal];
        [self.accountButton setTitle:SETTINGSVIEW_ACCOUNT_BUTTON_EDIT_USER forState:UIControlStateSelected];
        [self.loadingView stopAnimating];
        [self.loadingView setHidden:YES];
    }
    else if( self.manager.logStatus == LOG_STATE_PENDING ){
        
        self.userSettingLabel.text = SETTINGSVIEW_USERNAME_PENDING_SERVER;
        [self.logButton setTitle:SETTINGSVIEW_LOG_BUTTON_CANCEL forState:UIControlStateNormal];
        [self.logButton setTitle:SETTINGSVIEW_LOG_BUTTON_CANCEL forState:UIControlStateSelected];
        [self.accountButton setTitle:SETTINGSVIEW_ACCOUNT_BUTTON_SIGNUP forState:UIControlStateNormal];
        [self.accountButton setTitle:SETTINGSVIEW_ACCOUNT_BUTTON_SIGNUP forState:UIControlStateSelected];
        [self.loadingView startAnimating];
        [self.loadingView setHidden:NO];
    }
    else{
        
        self.userSettingLabel.text = ( self.manager.logStatus == LOG_STATE_LOGOUT ) ? SETTINGSVIEW_NOT_AVAILABLE : SETTINGSVIEW_USERNAME_ERROR;
        [self.logButton setTitle:SETTINGSVIEW_LOG_BUTTON_LOGIN forState:UIControlStateNormal];
        [self.logButton setTitle:SETTINGSVIEW_LOG_BUTTON_LOGIN forState:UIControlStateSelected];
        [self.accountButton setTitle:SETTINGSVIEW_ACCOUNT_BUTTON_SIGNUP forState:UIControlStateNormal];
        [self.accountButton setTitle:SETTINGSVIEW_ACCOUNT_BUTTON_SIGNUP forState:UIControlStateSelected];
        [self.loadingView stopAnimating];
        [self.loadingView setHidden:YES];
    }
}

-(void)AppManagerNetworkStatusChanged:(id)appmanager{
        
    if( !self.manager.netStatus ) self.netStatusLabel.text = SETTINGSVIEW_NETWORK_NOT_CONNECTED;
    else if( [self.manager.serverClient currentReachabilityStatus] == ReachableViaWiFi ) self.netStatusLabel.text = SETTINGSVIEW_NETWORK_WLAN;
    else self.netStatusLabel.text = SETTINGSVIEW_NETWORK_WWAN;
}

-(void)AppManagerGpsStatusChanged:(id)appmanager{
    
    if( !self.manager.gpsStatus ) self.gpsStatusLabel.text = SETTINGSVIEW_GPS_OFF;
    else if( self.manager.gpsManager.state == LOCATION_STATE_STATION ) self.gpsStatusLabel.text = SETTINGSVIEW_GPS_STATION;
    else self.gpsStatusLabel.text = SETTINGSVIEW_GPS_ON;
    
    [self AppManagerLocationChanged:appmanager];
}

-(void)AppManagerLocationChanged:(id)appmanager{
    
    if( self.manager.gpsStatus && CLLocationCoordinate2DIsValid(self.manager.gpsManager.coordinates) ) {
        
        self.latitudeStatusLabel.text = [NSString stringWithFormat:@"%0.13f", self.manager.user.coordinate.latitude];
        self.longitudeStatusLabel.text = [NSString stringWithFormat:@"%0.13f", self.manager.user.coordinate.longitude];
    }
    else {
        
        self.latitudeStatusLabel.text = SETTINGSVIEW_NOT_AVAILABLE;
        self.longitudeStatusLabel.text = SETTINGSVIEW_NOT_AVAILABLE;
    }
}

-(void)AppManagerServerStatusChanged:(id)appmanager{
   
    if( self.manager.serverStatus ) self.serverStatusLabel.text = SETTINGSVIEW_SERVER_ON;
    else self.serverStatusLabel.text = SETTINGSVIEW_SERVER_OFF;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if( buttonIndex ){
        
        CarGpsUser *user = [[CarGpsUser alloc] initWithUsername:[[alertView textFieldAtIndex:0] text] password:[[alertView textFieldAtIndex:1] text]];
        if( user ){
            self.manager.user = user;
            self.commandRequest = [self.manager  userLogin];
            [self.commandRequest addDelegate:self];
        }
        else [self loginAlert:self withUser:nil];
    }
}

-(void)serverCommandHanler:(id)command{
    
    if( !command ) return;
    if( ![self.commandRequest isEqual:command] ) return;
    
    [self.manager serverErrorHanler:self.commandRequest.error withAlert:YES];
    self.commandRequest = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if( [segue.identifier isEqualToString:@"AccountSegue"] ){
        
        AccountViewController *avc = segue.destinationViewController;
        avc.option = ( self.manager.logStatus == LOG_STATE_LOGIN ) ? ACCOUNT_VIEW_EDIT_USER : ACCOUNT_VIEW_SIGNUP;
        avc.manager = self.manager;
    }
    else if( [segue.identifier isEqualToString:@"StationSegue"] ){
        
        StationViewController *svc = segue.destinationViewController;
        svc.manager = self.manager;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if( [[textField restorationIdentifier] isEqualToString:@"Server"] || [[textField restorationIdentifier] isEqualToString:@"ServerUrl"] ){
        
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    }
    [textField endEditing:YES];
    return NO;
}
    


@end

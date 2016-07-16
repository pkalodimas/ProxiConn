//
//  MapSettingsViewController.m
//  CarGps
//
//  Created by Panos Kalodimas on 11/3/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "MapSettingsViewController.h"

@interface MapSettingsViewController ()

@end

@implementation MapSettingsViewController

@synthesize mapTypeSetting;
@synthesize mapRangeRetainSetting;
@synthesize mapUserFollowSetting;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self presentSettings];
}

-(void)presentSettings{
    
    NSMutableDictionary *settings = [self loadSettings];
    if( !settings ) return;
    
    if( [[settings valueForKey:SETTINGS_MAP_FOLLOW_USER] boolValue] ) self.mapUserFollowSetting.selectedSegmentIndex = 0;
    else self.mapUserFollowSetting.selectedSegmentIndex = 1;
    
    if( [[settings valueForKey:SETTINGS_MAP_RETAIN_RANGE] boolValue] ) self.mapRangeRetainSetting.selectedSegmentIndex = 0;
    else self.mapRangeRetainSetting.selectedSegmentIndex = 1;
    
    switch ([[settings valueForKey:SETTINGS_MAP_TYPE] integerValue]) {
        case MKMapTypeSatellite:{
            self.mapTypeSetting.selectedSegmentIndex = 2;
            break;
        }
        case MKMapTypeHybrid:{
            self.mapTypeSetting.selectedSegmentIndex = 1;
            break;
        }
        default:{
            self.mapTypeSetting.selectedSegmentIndex = 0;
            break;
        }
    }
}

-(IBAction)settingsValueChanged:(id)sender{
    
    if( [[sender restorationIdentifier] isEqualToString:@"MapType"] ){
        
        MKMapType type = MKMapTypeStandard;
        if( [sender selectedSegmentIndex] == 2 ) type = MKMapTypeSatellite;
        else if( [sender selectedSegmentIndex] == 1 ) type = MKMapTypeHybrid;
        
        [self editSetting:nil name:SETTINGS_MAP_TYPE value:[NSNumber numberWithInteger:type] save:YES];
    }
    else if( [[sender restorationIdentifier] isEqualToString:@"UserFollow"] ){
    
        [self editSetting:nil name:SETTINGS_MAP_FOLLOW_USER value:[NSNumber numberWithBool:( ([sender selectedSegmentIndex])?NO:YES )] save:YES];
    }
    else if( [[sender restorationIdentifier] isEqualToString:@"RangeRetain"] ){
        
        [self editSetting:nil name:SETTINGS_MAP_RETAIN_RANGE value:[NSNumber numberWithBool:( ([sender selectedSegmentIndex])?NO:YES )] save:YES];
    }
    
    [self.delegate mapSettingsValueChanged:sender];
}


@end

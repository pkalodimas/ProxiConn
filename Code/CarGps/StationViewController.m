//
//  StationViewController.m
//  proxiConn
//
//  Created by Panos Kalodimas on 11/28/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "StationViewController.h"

@interface StationViewController ()

@end

@implementation StationViewController

@synthesize latitudeText;
@synthesize longitudeText;
@synthesize stationModeSwitch;
@synthesize mapView;
@synthesize mapPin;
@synthesize manager;
@synthesize gpsStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.manager delegateAdd:self];
    self.gpsStatus = NO;

    self.stationModeSwitch.on = [[self getSetting:nil name:SETTINGS_STATION] boolValue];
    self.mapPin = [[MKPointAnnotation alloc] init];
    self.mapView.showsUserLocation = YES;
    [self currentLocationButton:self];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//---------------------------------------------------------------------------
//---------------------------- Gesture Delegates ----------------------------
//---------------------------------------------------------------------------

-(IBAction)currentLocationButton:(id)sender{
    
    [self.mapView removeAnnotation:self.mapPin];
    
    if( self.gpsStatus ) self.mapPin.coordinate = self.mapView.userLocation.coordinate;
    else {
        
        self.mapPin.coordinate = self.manager.gpsManager.coordinates;
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))];
    }
    
    [self.mapView addAnnotation:self.mapPin];
    
    self.latitudeText.text = [NSString stringWithFormat:@"%0.13f", self.mapPin.coordinate.latitude];
    self.longitudeText.text = [NSString stringWithFormat:@"%0.13f", self.mapPin.coordinate.longitude];
    
    [self.mapView setCenterCoordinate:self.mapPin.coordinate];
}

-(IBAction)mapLocationTapped:(UITapGestureRecognizer*)sender{
    
    [self.mapView removeAnnotation:self.mapPin];

    CLLocationCoordinate2D coordinates = [self.mapView convertPoint:[sender locationInView:self.mapView] toCoordinateFromView:self.mapView];
    self.mapPin.coordinate = coordinates;
    [self.mapView addAnnotation:self.mapPin];
    
    self.latitudeText.text = [NSString stringWithFormat:@"%0.13f", self.mapPin.coordinate.latitude];
    self.longitudeText.text = [NSString stringWithFormat:@"%0.13f", self.mapPin.coordinate.longitude];
}

-(IBAction)cancelButtonPushed:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)saveButtonPushed:(id)sender{
    
    NSMutableDictionary *settings = [self loadSettings];
    [self editSetting:settings name:SETTINGS_STATION value:[NSNumber numberWithBool:self.stationModeSwitch.on] save:NO];
    if( self.stationModeSwitch.on ){
        
        [self editSetting:settings name:SETTINGS_STATION_LATITUDE value:[NSNumber numberWithDouble:self.mapPin.coordinate.latitude] save:NO];
        [self editSetting:settings name:SETTINGS_STATION_LONGITUDE value:[NSNumber numberWithDouble:self.mapPin.coordinate.longitude] save:NO];
    }
    if( [self saveSettings:settings] ) {
        
        
        [self.manager restartLocationServices];
        [self infoAlert:@"Station Settings" withMessage:@"Settings successfully applied!"];
    }
    else [self infoAlert:@"Error!" withMessage:@"Settings apply failed!"];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if( [annotation isKindOfClass:[MKUserLocation class]] ) return NULL;
    
    MKPinAnnotationView *aview = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"point"];
    return aview;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    self.gpsStatus = YES;
}

-(void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
    
    self.gpsStatus = NO;
}


//---------------------------------------------------------------------------
//---------------------------- TextFields Delegates -------------------------
//---------------------------------------------------------------------------

-(void)textFieldDidEndEditing:(UITextField *)textField{
        
    double coor = [textField.text doubleValue];
    if( coor > -180 && coor < 180 ){
        
        if( [textField.restorationIdentifier isEqualToString:@"LatitudeText"] )self.mapPin.coordinate = CLLocationCoordinate2DMake(coor, self.mapPin.coordinate.longitude);
        else self.mapPin.coordinate = CLLocationCoordinate2DMake(self.mapPin.coordinate.latitude, coor);
        [self.mapView setCenterCoordinate:self.mapPin.coordinate animated:YES];
    }
    else [self infoAlert:@"Invalid coordinate" withMessage:@"Please set a valid value"];
    
    [self keyboardAnimation:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField endEditing:YES];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [self keyboardAnimation:NO];
}

-(void)keyboardAnimation:(Boolean)up{
    
    int pixels = ( up ) ? 200 : -200;
    
    [UIView beginAnimations:@"animations" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) self.view.frame = CGRectOffset(self.view.frame, pixels, 0);
    else if( self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ) self.view.frame = CGRectOffset(self.view.frame, -pixels, 0);
    else self.view.frame = CGRectOffset(self.view.frame, 0, pixels);
    [UIView commitAnimations];
}

@end

//
//  StationViewController.h
//  proxiConn
//
//  Created by Panos Kalodimas on 11/28/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "CarGpsAppManager.h"

@interface StationViewController : UIViewController <UITextFieldDelegate, MKMapViewDelegate, CarGpsAppManagerDelegate>{
    
    UITextField *latitudeText;
    UITextField *longitudeText;
    UISwitch *stationModeSwitch;
    MKMapView *mapView;
    MKPointAnnotation *mapPin;
    
    CarGpsAppManager *manager;
    BOOL gpsStatus;
}

@property(nonatomic, retain) IBOutlet UITextField *latitudeText;
@property(nonatomic, retain) IBOutlet UITextField *longitudeText;
@property(nonatomic, retain) IBOutlet UISwitch *stationModeSwitch;
@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) MKPointAnnotation *mapPin;
@property(nonatomic, retain) CarGpsAppManager *manager;
@property (assign,nonatomic) BOOL gpsStatus;

-(IBAction)cancelButtonPushed:(id)sender;
-(IBAction)saveButtonPushed:(id)sender;
-(IBAction)currentLocationButton:(id)sender;
-(IBAction)mapLocationTapped:(UITapGestureRecognizer*)sender;
-(void)keyboardAnimation:(Boolean)up;


@end

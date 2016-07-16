//
//  SecondViewController.h
//  CarGps
//
//  Created by Panos Kalodimas on 10/22/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "CarGpsAppManager.h"
#import "CarGpsAlerts.h"
#import "CarGpsServerCommand.h"
#import "CarGpsSettings.h"

#import "MainViewController.h"
#import "MapSettingsViewController.h"
#import "InfoViewController.h"

@interface MapViewController : UIViewController <CarGpsAppManagerDelegate, CarGpsServerCommandDelegate, MapSettingsDelegate, MKMapViewDelegate> {
    
    UILabel *userLabel;
    UIButton *locationButton;
    UIButton *neighbourButton;
    UIActivityIndicatorView *neighboursLoadingView;
    
    UILabel *serverLabel;
    UILabel *networkLabel;
    UILabel *gpsLabel;
    UIView *infoView;
    
    MKMapView *mapView;
    CarGpsServerCommand *commandRequest;
    CarGpsAppManager *manager;
}

@property (retain,nonatomic) IBOutlet UILabel *userLabel;
@property (retain,nonatomic) IBOutlet UIButton *locationButton;
@property (retain,nonatomic) IBOutlet UIButton *neighbourButton;;
@property (retain,nonatomic) IBOutlet UIActivityIndicatorView *neighboursLoadingView;

@property (retain,nonatomic) IBOutlet UILabel *serverLabel;
@property (retain,nonatomic) IBOutlet UILabel *gpsLabel;
@property (retain,nonatomic) IBOutlet UILabel *networkLabel;
@property (retain,nonatomic) IBOutlet UIView *infoView;

@property (retain,nonatomic) IBOutlet MKMapView *mapView;
@property (retain,nonatomic) CarGpsServerCommand *commandRequest;;
@property (retain,nonatomic) CarGpsAppManager *manager;

-(IBAction)locationButtonPushed:(id)sender;
-(IBAction)neighbourButtonPushed:(id)sender;

-(MKCoordinateRegion)defaultRegion;
-(void)mapUserCentralize:(MKCoordinateRegion)region;
-(void)mapUpdateNeigbours;

@end

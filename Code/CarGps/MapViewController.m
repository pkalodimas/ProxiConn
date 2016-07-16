//
//  SecondViewController.m
//  CarGps
//
//  Created by Panos Kalodimas on 10/22/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize userLabel;
@synthesize locationButton;
@synthesize neighbourButton;
@synthesize serverLabel;
@synthesize gpsLabel;
@synthesize networkLabel;
@synthesize infoView;
@synthesize neighboursLoadingView;
@synthesize mapView;
@synthesize commandRequest;
@synthesize manager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [(MainViewController*)self.parentViewController manager];
    [self.manager delegateAdd:self];
    
    NSMutableDictionary *settings = [self loadSettings];
    
    self.mapView.mapType = [[self getSetting:settings name:SETTINGS_MAP_TYPE] integerValue];    
    self.commandRequest = nil;
    self.neighboursLoadingView.hidden = YES;
    self.mapView.scrollEnabled = ![[self getSetting:settings name:SETTINGS_MAP_FOLLOW_USER] boolValue];
    self.mapView.zoomEnabled = ![[self getSetting:settings name:SETTINGS_MAP_RETAIN_RANGE] boolValue];
    self.mapView.showsUserLocation = NO;
    self.mapView.region = [self defaultRegion];
    [self mapUserCentralize:self.mapView.region];
    if( !self.manager.gpsStatus ) [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))];
}

-(void)viewWillAppear:(BOOL)animated{
        
    [self AppManagerGpsStatusChanged:self.manager];
    [self AppManagerNetworkStatusChanged:self.manager];
    [self AppManagerServerStatusChanged:self.manager];
    [self AppManagerLogStatusChanged:self.manager];
    [self AppManagerLocationChanged:self.manager];
    [self AppManagerNeighboursUpdated:self.manager];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---------------------------------------------------------------------------
//---------------------------- Private Methods ------------------------------
//---------------------------------------------------------------------------

-(MKCoordinateRegion)defaultRegion{

    double drange = (double) [[self getSetting:nil name:SETTINGS_NEIGHBOUR_RANGE] integerValue];
    if( drange == 0 ) drange = 10000;
    return MKCoordinateRegionMake(self.manager.gpsManager.location.coordinate, MKCoordinateSpanMake(drange/SETTINGS_LATITUDE_RATIO, 0));
}

-(void)mapUserCentralize:(MKCoordinateRegion)region{
    
    if( !self.manager.gpsStatus ) return;
    
    if( !self.mapView.zoomEnabled ) region = [self defaultRegion];
    
    if( CLLocationCoordinate2DIsValid(region.center) ) [self.mapView setRegion:region animated:YES];
    if( CLLocationCoordinate2DIsValid(self.manager.gpsManager.coordinates) ) [self.mapView setCenterCoordinate:self.manager.gpsManager.coordinates animated:YES];
}

-(void)mapUpdateNeigbours{
    
    NSMutableArray *annotationsArray = [NSMutableArray array];
    
    if( self.manager.neighbours.count > 0 ) [annotationsArray addObjectsFromArray:self.manager.neighbours];
    if( self.manager.user ) [annotationsArray addObject:self.manager.user];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotationsArray];
}

-(void)mapSettingsValueChanged:(id)sender{
    
    if( [[sender restorationIdentifier] isEqualToString:@"MapType"] ){
        
        if( [sender selectedSegmentIndex] == 2 ) self.mapView.mapType = MKMapTypeSatellite;
        else if( [sender selectedSegmentIndex] == 1 ) self.mapView.mapType = MKMapTypeHybrid;
        else self.mapView.mapType = MKMapTypeStandard;
    }
    else if( [[sender restorationIdentifier] isEqualToString:@"UserFollow"] ){
        
        self.mapView.scrollEnabled = ( [sender selectedSegmentIndex] ) ? YES : NO;
        if( !self.mapView.scrollEnabled ) [self mapUserCentralize:self.mapView.region];
    }
    else if( [[sender restorationIdentifier] isEqualToString:@"RangeRetain"] ){
        
        self.mapView.zoomEnabled = ( [sender selectedSegmentIndex] ) ? YES : NO;
        if( !self.mapView.zoomEnabled ) [self mapUserCentralize:[self defaultRegion]];
    }
}

//---------------------------------------------------------------------------
//---------------------------------- Buttons --------------------------------
//---------------------------------------------------------------------------

-(IBAction)locationButtonPushed:(id)sender{
    
    if( self.manager.gpsStatus ){

        [self mapUserCentralize:self.mapView.region];
    }
    else [self noGPSAlert];
}

-(IBAction)neighbourButtonPushed:(id)sender{
    
    if( self.manager.netStatus && self.manager.logStatus == LOG_STATE_LOGIN ) {
        
        if( self.commandRequest ) return;
            
        self.commandRequest = [self.manager userNeighboursUpdate];
        if( self.commandRequest ){
        
            [self.commandRequest addDelegate:self];
            self.neighboursLoadingView.hidden = NO;
            [self.neighboursLoadingView startAnimating];
        }
    }
    else if( !self.manager.netStatus ) [self noNetworkAlert];
    else [self noLoginAlert];
}

//---------------------------------------------------------------------------
//---------------------------- Manager Delegates ----------------------------
//---------------------------------------------------------------------------

-(void)AppManagerNetworkStatusChanged:(id)appmanager{
    
    if( self.manager.netStatus ) {
        
        self.networkLabel.text = MAPVIEW_NETWORKLABEL_ON;
        self.networkLabel.textColor = [UIColor greenColor];
        if( self.manager.gpsStatus && self.manager.serverStatus ) self.infoView.hidden = YES;
    }
    else{
        
        self.networkLabel.text = MAPVIEW_NETWORKLABEL_OFF;
        self.networkLabel.textColor = [UIColor redColor];
        self.infoView.hidden = NO;
    }
    [self.infoView setNeedsDisplay];
}

-(void)AppManagerGpsStatusChanged:(id)appmanager{
    
    if( self.manager.gpsStatus ) {
        
        self.gpsLabel.text = MAPVIEW_GPSLABEL_ON;
        self.gpsLabel.textColor = [UIColor greenColor];
        if( self.manager.netStatus && self.manager.serverStatus ) self.infoView.hidden = YES;
        [self mapUserCentralize:self.mapView.region];
    }
    else{
        
        self.gpsLabel.text = MAPVIEW_GPSLABEL_OFF;
        self.gpsLabel.textColor = [UIColor redColor];
        self.infoView.hidden = NO;
    }
    [self.infoView setNeedsDisplay];
}

-(void)AppManagerServerStatusChanged:(id)appmanager{
    
    if( self.manager.serverStatus ) {
        
        self.serverLabel.text = MAPVIEW_SERVERLABEL_ON;
        self.serverLabel.textColor = [UIColor greenColor];
        if( self.manager.gpsStatus && self.manager.netStatus ) self.infoView.hidden = YES;
    }
    else{
        
        self.serverLabel.text = MAPVIEW_SERVERLABEL_OFF;
        self.serverLabel.textColor = [UIColor redColor];
        self.infoView.hidden = NO;
    }
    [self.infoView setNeedsDisplay];
}

-(void)AppManagerLocationChanged:(id)manager{
    
    if( !self.mapView.scrollEnabled ) [self mapUserCentralize:self.mapView.region];
}

-(void)AppManagerLogStatusChanged:(id)appmanager{
    
    if( self.manager.logStatus == LOG_STATE_LOGIN ) self.userLabel.text = [MAPVIEW_USERLABEL_LOGGED stringByAppendingString:self.manager.user.username];
    else self.userLabel.text = MAPVIEW_USERLABEL_UNLOGGED;
    [self mapUserCentralize:self.mapView.region];
}

-(void)AppManagerNeighboursUpdated:(id)appmanager{
 
    [self mapUpdateNeigbours];
}

-(void)serverCommandHanler:(id)command{

    if( !command ) return;
    if( [self.commandRequest isEqual:command] ){
        
        [self.neighboursLoadingView stopAnimating];
        [self.neighboursLoadingView setHidden:YES];
        [self.manager serverErrorHanler:self.commandRequest.error withAlert:YES];
        self.commandRequest = nil;
    }
}

//---------------------------------------------------------------------------
//---------------------------- Map Delegates --------------------------------
//---------------------------------------------------------------------------

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if( !self.mapView.scrollEnabled ) [self mapUserCentralize:self.mapView.region];
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //if( [annotation isKindOfClass:[MKUserLocation class]] ) return NULL;
    if( [annotation isEqual:self.manager.user] ) return nil;
    
    MKPinAnnotationView *aview = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"member"];
    [aview setPinColor:MKPinAnnotationColorGreen];
    aview.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
    aview.canShowCallout = YES;
    return aview;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    [self performSegueWithIdentifier:@"mapUserInfoSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if( [segue.identifier isEqualToString:@"MapSettingsSegue"] ){
        
        MapSettingsViewController *dvc = segue.destinationViewController;
        dvc.delegate = self;
    }
    else if( [segue.identifier isEqualToString:@"mapUserInfoSegue"] ){
        
        InfoViewController *dvc = segue.destinationViewController;
        dvc.manager = self.manager;
        dvc.user = [self.mapView.selectedAnnotations objectAtIndex:0];
    }
}

@end

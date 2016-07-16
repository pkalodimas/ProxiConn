//
//  CarGpsLocationManager.m
//  proxiConn
//
//  Created by Panos Kalodimas on 12/3/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsLocationManager.h"

@implementation CarGpsLocationManager

@synthesize coordinates;
@synthesize state;
@synthesize locationDelegate;

-(id)initWithState:(LocationState)locationState{
    
    self = [super init];
    [super setDelegate:self];
    
    self.state = locationState;
    self.locationDelegate = nil;
    self.coordinates = CLLocationCoordinate2DMake(0, 0);
    
    return self;
}

-(id)initWithDelegate:(id<CarGpsLocationManagerDelegate>)del{
    
    self = [super init];
    [super setDelegate:self];
    
    self.locationDelegate = del;
    self.state = LOCATION_STATE_OFF;
    self.coordinates = CLLocationCoordinate2DMake(0, 0);

    return  self;
}

-(void)initWithSettings:(NSMutableDictionary *)settings{
    
    if( !settings ) return;
    
    [self setDistanceFilter:[[self getSetting:settings name:SETTINGS_GPS_DISTANCE_FILTER] integerValue]];
    [self setDesiredAccuracy:[[self getSetting:settings name:SETTINGS_GPS_ACCURACY] integerValue]];
    [self setActivityType:[[self getSetting:settings name:SETTINGS_GPS_ACCURACY] integerValue]];
    [self setPausesLocationUpdatesAutomatically:YES];
        
    self.state = ( [[self getSetting:settings name:SETTINGS_STATION] boolValue] ) ? LOCATION_STATE_STATION : LOCATION_STATE_OFF;
}

-(void)startLocationService{
    
    if( self.state == LOCATION_STATE_STATION ) {
        
        self.coordinates = [self loadStationCoordinates:nil];
        [self.locationDelegate LocationManagerStateChanged:LOCATION_STATE_STATION];
        [self.locationDelegate LocationManagerLocationChanged:self.coordinates];
    }
    else [self startUpdatingLocation];
}

-(void)stopLocationService{
    
    self.state = LOCATION_STATE_OFF;
    [self stopUpdatingLocation];
    [self.locationDelegate LocationManagerStateChanged:LOCATION_STATE_OFF];
}

-(void)restartLocationService{
    
    [self stopLocationService];
    [self initWithSettings:[self loadSettings]];
    [self startLocationService];
}

-(void)enableStationMode:(CLLocationCoordinate2D)stationCoordinates{
    
    self.state = LOCATION_STATE_STATION;
    [self stopUpdatingLocation];
    self.coordinates = stationCoordinates;

    [self.locationDelegate LocationManagerStateChanged:self.state];
    [self.locationDelegate LocationManagerLocationChanged:self.coordinates];
}

-(void)disableStationMode{
    
    self.state = LOCATION_STATE_OFF;
    [self.locationDelegate LocationManagerStateChanged:self.state];
    [self startUpdatingLocation];
}

//---------------------------------------------------------------------------
//---------------------------- CLLocationManager Delegate -------------------
//---------------------------------------------------------------------------

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    
    if( self.state == LOCATION_STATE_STATION ) return;
    
    self.state = LOCATION_STATE_OFF;
    [self.locationDelegate LocationManagerStateChanged:self.state];
}


-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
    
    if( self.state == LOCATION_STATE_STATION ) return;
    
    self.state = LOCATION_STATE_ON;
    [self.locationDelegate LocationManagerStateChanged:self.state];
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if( self.state == LOCATION_STATE_STATION ) return;
    
    if (status == kCLAuthorizationStatusAuthorized) [self startUpdatingLocation];
    else {
        
        self.state = LOCATION_STATE_OFF;
        [self.locationDelegate LocationManagerStateChanged:self.state];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if( self.state == LOCATION_STATE_STATION ) return;
    
    if( self.state == LOCATION_STATE_ON ){
        
        self.state = LOCATION_STATE_OFF;
        [self.locationDelegate LocationManagerStateChanged:self.state];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if( self.state == LOCATION_STATE_STATION ) return;

    self.coordinates = [(CLLocation*)[locations lastObject] coordinate];
    
    if( self.state == LOCATION_STATE_OFF ) {
        
        self.state = LOCATION_STATE_ON;
        [self.locationDelegate LocationManagerStateChanged:self.state];
    }
    
    [self.locationDelegate LocationManagerLocationChanged:self.coordinates];
}


@end

//
//  CarGpsLocationManager.h
//  proxiConn
//
//  Created by Panos Kalodimas on 12/3/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "AppDefinitions.h"
#import "CarGpsSettings.h"


@protocol CarGpsLocationManagerDelegate @optional

-(void)LocationManagerStateChanged:(LocationState)state;
-(void)LocationManagerLocationChanged:(CLLocationCoordinate2D)coordinates;

@end

@interface CarGpsLocationManager : CLLocationManager <CLLocationManagerDelegate>{
    
    CLLocationCoordinate2D coordinates;
    LocationState state;
    id<CarGpsLocationManagerDelegate> locationDelegate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, assign) LocationState state;
@property (nonatomic, retain) id locationDelegate;

-(id)initWithState:(LocationState)locationState;
-(id)initWithDelegate:(id<CarGpsLocationManagerDelegate>)del;

-(void)initWithSettings:(NSMutableDictionary*)settings;

-(void)startLocationService;
-(void)stopLocationService;
-(void)restartLocationService;

-(void)enableStationMode:(CLLocationCoordinate2D)stationCoordinates;
-(void)disableStationMode;

@end

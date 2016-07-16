//
//  user.h
//  CarGPS
//
//  Created by Panos Kalodimas on 9/19/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "AppDefinitions.h"

@interface CarGpsUser : NSObject <MKAnnotation> {
    
    NSString *username;
    NSString *password;
    NSMutableDictionary *info;
    CLLocationCoordinate2D coordinate;
    double distance;
    LocationDirection direction;
    NSString *title;
}

@property (retain, nonatomic) NSString *username;
@property (retain, nonatomic) NSString *password;
@property (retain, nonatomic) NSMutableDictionary *info;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) double distance;
@property (assign, nonatomic) LocationDirection direction;
@property (nonatomic, copy) NSString *title;


-(CarGpsUser*)initWithUsername:(NSString*)name password:(NSString*)pass;
-(CarGpsUser*)initUserFromDictionary:(NSDictionary*)dict;
//-(CarGpsUser*)initUserFromFile:(NSString*)filepath;
-(CarGpsUser*)initFromUser:(CarGpsUser*)user;
-(CarGpsUser*)initNeighbour:(NSDictionary*)info;

-(NSMutableDictionary*)infoFromDictionary:(NSDictionary*)dict;
-(void)editFromUser:(CarGpsUser*)user;
-(void)countDinstane:(CLLocationCoordinate2D)point;
-(LocationDirection)countDirection:(CLLocationCoordinate2D)point;

@end


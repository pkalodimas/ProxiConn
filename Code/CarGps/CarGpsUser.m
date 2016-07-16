//
//  user.m
//  CarGPS
//
//  Created by Panos Kalodimas on 9/19/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsUser.h"

@implementation CarGpsUser

@synthesize username;
@synthesize password;
@synthesize info;
@synthesize distance;
@synthesize direction;
@synthesize coordinate;
@synthesize title;


-(CarGpsUser*)init{
    
    self = [super init];
    
    self.username = @"";
    self.password = @"";
    self.info = [NSMutableDictionary dictionary];
    self.distance = 0;
    self.direction = DIRECTION_ERROR;
    self.coordinate = CLLocationCoordinate2DMake(0, 0);
    self.title = @"";
    
    return self;
}


-(CarGpsUser*)initWithUsername:(NSString *)name password:(NSString *)pass{
    
    if( !name || [name isEqualToString:@""] ) return nil;
    if( !pass || [pass isEqualToString:@""] ) return nil;

    self = [self init];
    
    self.username = name;
    self.password = pass;
    
    return self;
}

-(CarGpsUser*)initUserFromDictionary:(NSDictionary *)dict{
    
    if( !dict ) return nil;
    
    self = [self init];
    
    self.username = [dict valueForKey:USERNAME];
    self.password = [dict valueForKey:PASSWORD];
    self.info = [dict valueForKey:INFO];
    
    if (!self.username || !self.password) return nil;
    if( !self.info ) [self infoFromDictionary:dict];
    if( !self.info ) self.info = [NSMutableDictionary dictionary];

    return self;
}

/*
-(CarGpsUser*)initUserFromFile:(NSString *)filepath{
    
    self = [self init];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    return [self initUserFromDictionary:dict];
}
 */

-(CarGpsUser*)initFromUser:(CarGpsUser *)user{
    
    if( !user ) return nil;
    if( !user.username || !user.password ) return nil;
    
    self = [self init];
    
    self.username = user.username;
    self.password = user.password;
    self.info = [NSMutableDictionary dictionaryWithDictionary:user.info];
    if( !self.info ) self.info = [NSMutableDictionary dictionary];
    self.distance = user.distance;
    self.coordinate = CLLocationCoordinate2DMake(user.coordinate.latitude, user.coordinate.longitude);
    
    return self;
}

-(NSMutableDictionary*)infoFromDictionary:(NSDictionary *)dict{
    
    if( !dict ) return nil;
    if( !self.info ) self.info = [NSMutableDictionary dictionary];
    
    [self.info setValue:[dict valueForKey:NAME] forKey:NAME];
    [self.info setValue:[dict valueForKey:EMAIL] forKey:EMAIL];
    [self.info setValue:[dict valueForKey:FACEBOOK] forKey:FACEBOOK];
    
    return self.info;
}

-(void)editFromUser:(CarGpsUser *)user{
    
    if( !user ) return;
    if( !user.username || !user.password  || !user.info ) return;
    
    self.username = user.username;
    self.password = user.password;
    self.info = [NSMutableDictionary dictionaryWithDictionary:user.info];
}

-(CarGpsUser*)initNeighbour:(NSDictionary *)dict{
    
    if( !dict ) return NULL;
    
    self = [self init];
    
    self.username = [dict valueForKey:USERNAME];
    self.coordinate = CLLocationCoordinate2DMake([[dict valueForKey:COORDINATE_Y] doubleValue], [[dict valueForKey:COORDINATE_X] doubleValue]);
    self.title = self.username;
    self.info = nil;
    
    if( !self.username || !CLLocationCoordinate2DIsValid(self.coordinate) ) return NULL;
    
    return self;
}

-(void)countDinstane:(CLLocationCoordinate2D)point{
    
    self.distance = [[[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude] distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude]];
    self.direction = [self countDirection:point];
}

-(LocationDirection)countDirection:(CLLocationCoordinate2D)point{
    
    double dy = self.coordinate.latitude - point.latitude;
    double dx = self.coordinate.longitude - point.longitude;
    
    if( dy >= 0 && fabs(dy) > fabs(dx) ) return DIRECTION_NORTH;
    if( dy < 0 && fabs(dy) > fabs(dx) ) return DIRECTION_SOUTH;
    if( dx >= 0 ) return DIRECTION_EAST;
    if( dx < 0 ) return DIRECTION_WEST;
    return DIRECTION_ERROR;
}







@end

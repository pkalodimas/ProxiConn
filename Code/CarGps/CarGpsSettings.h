//
//  NSObject+CarGpsSettings.h
//  CarGPS
//
//  Created by Panos Kalodimas on 10/20/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDefinitions.h"
#import "CarGpsUser.h"

@interface NSObject (CarGpsSettings)

//Settings method
-(NSMutableDictionary*)loadSettings;
-(BOOL)saveSettings:(NSMutableDictionary*)settings;
-(id)getSetting:(NSMutableDictionary*)settings name:(NSString*)name;
-(BOOL)editSetting:(NSMutableDictionary*)settings name:(NSString*)name value:(id)value save:(Boolean)save;
-(NSMutableDictionary*)defaultSettings;
-(id)getDefaultSettingValue:(NSString*)name;

//CarGps methods
-(BOOL)saveLastUser:(CarGpsUser*)user toSettings:(NSMutableDictionary*)settings;
-(BOOL)removeLastUser:(NSMutableDictionary*)settings;
-(CarGpsUser*)loadLastUser:(NSMutableDictionary*)settings;
-(CLLocationCoordinate2D)loadStationCoordinates:(NSMutableDictionary*)settings;

@end

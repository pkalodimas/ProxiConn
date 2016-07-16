//
//  NSObject+CarGpsSettings.m
//  CarGPS
//
//  Created by Panos Kalodimas on 10/20/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsSettings.h"

@implementation NSObject (CarGpsSettings)

//---------------------------------------------------------------------------
//----------------------------- Settings Methods ----------------------------
//---------------------------------------------------------------------------

-(NSMutableDictionary*)loadSettings{
    
    NSString *filepath = [DOCUMENTS_FOLDERPATH stringByAppendingPathComponent:SETTINGS_FILE_NAME] ;
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (!settings)  settings = [self defaultSettings];
    
    return  settings;
}

-(NSMutableDictionary*)defaultSettings{
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:DEFAULT_SETTINGS, nil];
}

-(BOOL)saveSettings:(NSMutableDictionary*)settings{
    
    if( !settings ) return NO;
    NSString *filepath = [DOCUMENTS_FOLDERPATH stringByAppendingPathComponent:SETTINGS_FILE_NAME] ;

    return [settings writeToFile:filepath atomically:YES];
}

-(id)getSetting:(NSMutableDictionary*)settings name:(NSString *)name{
    
    if (!settings) settings = [self loadSettings];
    if (!settings) return nil;
    
    id value = [settings valueForKey:name];
    
    if( value ) return value;
    else return [self getDefaultSettingValue:name];
}

-(BOOL)editSetting:(NSMutableDictionary*)settings name:(NSString *)name value:(id)value save:(Boolean)save{
    
    if( !name || !value ) return NO;
    if (!settings) settings = [self loadSettings];
    if (!settings) return NO;
    
    [settings setValue:value forKey:name];
    if( save ) return [self saveSettings:settings];
    return YES;
}

-(id)getDefaultSettingValue:(NSString *)name{
    
    if( !name ) return NULL;
    
    NSMutableDictionary *defaults = [self defaultSettings];
    return [self getSetting:defaults name:name];
}


//---------------------------------------------------------------------------
//----------------------------- CarGps Methods -----------------------------
//---------------------------------------------------------------------------

-(BOOL)saveLastUser:(CarGpsUser *)user toSettings:(NSMutableDictionary *)settings{
    
    if( !user ) return NO;
    if( !user.username || !user.password ) return NO;
    if( !settings ) settings = [self loadSettings];
    
    [settings setValue:user.username forKey:USERNAME];
    [settings setValue:user.password forKey:PASSWORD];
    
    return [self saveSettings:settings];
}

-(BOOL)removeLastUser:(NSMutableDictionary *)settings{
    
    if( !settings ) settings = [self loadSettings];
    if( !settings ) return NO;
    
    [settings removeObjectForKey:USERNAME];
    [settings removeObjectForKey:PASSWORD];
    
    return [self saveSettings:settings];
}

-(CarGpsUser*)loadLastUser:(NSMutableDictionary*)settings {
    
    if( !settings ) settings = [self loadSettings];
    if( !settings ) return NO;

    return [[CarGpsUser alloc] initUserFromDictionary:settings];
}

-(CLLocationCoordinate2D)loadStationCoordinates:(NSMutableDictionary*)settings{
    
    if( !settings ) settings = [self loadSettings];
    if( !settings ) return CLLocationCoordinate2DMake(0, 0);

    return CLLocationCoordinate2DMake([[self getSetting:settings name:SETTINGS_STATION_LATITUDE] doubleValue], [[self getSetting:settings name:SETTINGS_STATION_LONGITUDE] doubleValue]);
}



@end

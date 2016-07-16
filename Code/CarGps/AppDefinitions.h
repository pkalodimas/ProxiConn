//
//  AppDefinitions.h
//  CarGPS
//
//  Created by Panos Kalodimas on 9/14/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#ifndef CarGPS_AppDefinitions_h
#define CarGPS_AppDefinitions_h


//DICTIONARY WORDS DEFINITIONS
#define COMMAND                     @"command"
#define COORDINATE_X                @"x"
#define COORDINATE_Y                @"y"
#define RANGE                       @"range"
#define EMAIL                       @"email"
#define ERROR                       @"error"
#define FACEBOOK                    @"facebook"
#define INFO                        @"info"
#define MESSAGE                     @"message"
#define NAME                        @"name"
#define NEIGHBOURS                  @"neighbors"
#define PASSWORD                    @"password"
#define PLIST                       @"plist"
#define SESSION                     @"sid"
#define USERNAME                    @"username"
#define STATION                     @"station"

//OTHER DEFINITIONS
#define HTTP_POST                   @"Post"
#define EMPTY_STRING                @""


//USER GRAPHIC INTERFACE DEFINITIONS
#define SETTINGSVIEW_ACCOUNT_BUTTON_SIGNUP              @"Signup"
#define SETTINGSVIEW_ACCOUNT_BUTTON_EDIT_USER           @"Edit User"
#define SETTINGSVIEW_LOG_BUTTON_LOGIN                   @"Login"
#define SETTINGSVIEW_LOG_BUTTON_LOGOUT                  @"Logout"
#define SETTINGSVIEW_LOG_BUTTON_CANCEL                  @"Cancel"
#define SETTINGSVIEW_NOT_AVAILABLE                      @"N/A"
#define SETTINGSVIEW_USERNAME_PENDING_SERVER            @"...Pending Server"
#define SETTINGSVIEW_USERNAME_ERROR                     @"...Invalid"
#define SETTINGSVIEW_NETWORK_NOT_CONNECTED              @"Not Connected"
#define SETTINGSVIEW_NETWORK_WLAN                       @"WIFI"
#define SETTINGSVIEW_NETWORK_WWAN                       @"WWAN"
#define SETTINGSVIEW_GPS_ON                             @"ON"
#define SETTINGSVIEW_GPS_OFF                            @"OFF"
#define SETTINGSVIEW_GPS_STATION                        @"STATION"
#define SETTINGSVIEW_SERVER_OFF                         @"Pending"
#define SETTINGSVIEW_SERVER_ON                          @"Connected"
#define SETTINGSVIEW_STATION_ON                         @"ON"
#define SETTINGSVIEW_STATION_OFF                        @"OFF"

#define ACCOUNTVIEW_CONFIRM_BUTTON_EDIT_USER            @"Save"
#define ACCOUNTVIEW_CONFIRM_BUTTON_SIGNUP               @"Signup"
#define ACCOUNTVIEW_TITLE_SIGNUP                        @"Signup"
#define ACCOUNTVIEW_TITLE_EDIT_USER                     @"Edit User"

#define MEMBERSVIEW_SECTION_TITLE                       @"Neighbors"
#define MEMBERSVIEW_DIRECTION_NORTH                     @"North"
#define MEMBERSVIEW_DIRECTION_SOUTH                     @"South"
#define MEMBERSVIEW_DIRECTION_WEST                      @"West"
#define MEMBERSVIEW_DIRECTION_EAST                      @"East"
#define MEMBERSVIEW_NOT_AVAILABLE                       @"N/A"
#define MEMBERSVIEW_PENDING_SERVER                      @"...Pending Server"
#define MEMBERSVIEW_IMAGE_WEST                          @"west"
#define MEMBERSVIEW_IMAGE_EAST                          @"east"
#define MEMBERSVIEW_IMAGE_NORTH                         @"north"
#define MEMBERSVIEW_IMAGE_SOUTH                         @"south"
#define MEMBERSVIEW_IMAGE_TYPE                          @"png"

#define MAPVIEW_USERLABEL_UNLOGGED                      @"No user logged"
#define MAPVIEW_USERLABEL_LOGGED                        @"User : "
#define MAPVIEW_SERVERLABEL_ON                          @"ON"
#define MAPVIEW_SERVERLABEL_OFF                         @"OFF"
#define MAPVIEW_GPSLABEL_ON                             @"ON"
#define MAPVIEW_GPSLABEL_OFF                            @"OFF"
#define MAPVIEW_GPSLABEL_STATION                        @"STATION"
#define MAPVIEW_NETWORKLABEL_ON                         @"ON"
#define MAPVIEW_NETWORKLABEL_OFF                        @"OFF"

//APPLICATION SETTINGS DEFINITIONS
#define DOCUMENTS_FOLDERPATH                 [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path]
#define SETTINGS_FILE_NAME                   @"Settings.plist"

#define SETTINGS_NEIGHBOUR_RANGE             @"neighbor_range"
#define SETTINGS_REMEMBER_LAST_USER          @"last_user"
#define SETTINGS_SESSION_UPDATE_TIME         @"session_uptime"
#define SETTINGS_NEIGHBOUR_UPDATE_TIME       @"neighbor_uptime"
#define SETTINGS_SERVER                      @"server"
#define SETTINGS_SERVER_URL                  @"server_url"
#define SETTINGS_LATITUDE_RATIO              100000
#define SETTINGS_MAP_TYPE                    @"map_type"
#define SETTINGS_MAP_FOLLOW_USER             @"map_follow_user"
#define SETTINGS_MAP_RETAIN_RANGE            @"map_retain_range"
#define SETTINGS_AUTOLOGIN                   @"autologin"
#define SETTINGS_GPS_ACCURACY                @"gps_accuracy"
#define SETTINGS_GPS_DISTANCE_FILTER         @"gps_distance_filter"
#define SETTINGS_GPS_ACTIVITY                @"gps_activity"
#define SETTINGS_STATION                     @"station"
#define SETTINGS_STATION_LATITUDE            @"latitude"
#define SETTINGS_STATION_LONGITUDE           @"longitude"

//SETTINGS DEFAULTS DEFINITIONS
#define DEFAULT_NEIGHBOUR_RANGE             1000
#define DEFAULT_SESSION_UPDATE_TIME         5
#define DEFAULT_NEIGHBOUR_UPDATE_TIME       10
#define DEFAULT_REMEMBER_LAST_USER          YES
#define DEFAULT_AUTOLOGIN                   YES
#define DEFAULT_SERVER                      @"prometheus.ece.tuc.gr"
#define DEFAULT_SERVER_URL                  @"/clients/index.php"
#define DEFAULT_MAP_TYPE                    MAP_TYPE_MAP
#define DEFAULT_MAP_FOLLOW_USER             YES
#define DEFAULT_MAP_RETAIN_RANGE            NO
#define DEFAULT_GPS_ACCURACY                kCLLocationAccuracyBest
#define DEFAULT_GPS_DISTANCE_FILTER         5
#define DEFAULT_GPS_ACTIVITY                CLActivityTypeOtherNavigation
#define DEFAULT_STATION                     NO
#define DEFAULT_STATION_LATITUDE            0
#define DEFAULT_STATION_LONGITUDE           0

#define DEFAULT_SETTINGS   [NSNumber numberWithInt:DEFAULT_NEIGHBOUR_RANGE], SETTINGS_NEIGHBOUR_RANGE, [NSNumber numberWithInt:DEFAULT_SESSION_UPDATE_TIME], SETTINGS_SESSION_UPDATE_TIME, [NSNumber numberWithBool:DEFAULT_REMEMBER_LAST_USER], SETTINGS_REMEMBER_LAST_USER, DEFAULT_SERVER, SETTINGS_SERVER, DEFAULT_SERVER_URL, SETTINGS_SERVER_URL, [NSNumber numberWithInt:DEFAULT_NEIGHBOUR_UPDATE_TIME], SETTINGS_NEIGHBOUR_UPDATE_TIME, [NSNumber numberWithInt:DEFAULT_MAP_TYPE], SETTINGS_MAP_TYPE, [NSNumber numberWithBool:DEFAULT_AUTOLOGIN], SETTINGS_AUTOLOGIN, [NSNumber numberWithInt:DEFAULT_GPS_ACCURACY], SETTINGS_GPS_ACCURACY, [NSNumber numberWithInt:DEFAULT_GPS_DISTANCE_FILTER], SETTINGS_GPS_DISTANCE_FILTER,[NSNumber numberWithInt:DEFAULT_GPS_ACTIVITY], SETTINGS_GPS_ACTIVITY, [NSNumber numberWithBool:DEFAULT_MAP_FOLLOW_USER], SETTINGS_MAP_FOLLOW_USER, [NSNumber numberWithBool:DEFAULT_MAP_RETAIN_RANGE], SETTINGS_MAP_RETAIN_RANGE, [NSNumber numberWithBool:DEFAULT_STATION], SETTINGS_STATION, [NSNumber numberWithDouble:DEFAULT_STATION_LATITUDE], SETTINGS_STATION_LATITUDE, [NSNumber numberWithDouble:DEFAULT_STATION_LONGITUDE], SETTINGS_STATION_LONGITUDE

typedef enum{
    SERVER_NO_COMMAND = 0,
    SERVER_LOGIN = 1,
    SERVER_LOGOUT = 2,
    SERVER_UPDATE_LOCATION = 3,
    SERVER_NEIGHBOURS = 4,
    SERVER_USER_INFO = 5,
    SERVER_SIGNUP = 6,
    SERVER_SIGNOUT = 7,
    SERVER_EDIT_USER = 8,
} ServerCommands;
#define SERVER_COMMANDS_NUMBER 8


//Error Messages
#define NO_ERROR_MESSAGE                                @"Operation completed successfully."
#define ERROR_SERVER_NOT_RESPOND_MESSAGE                @"Server did not Respond. Server not reachable."
#define ERROR_USER_CANCEL_MESSAGE                       @"User canceled command."
#define ERROR_SQL_CONNECT_MESSAGE                       @"SQL server connection error."
#define ERROR_SQL_SERVER_MESSAGE                        @"SQL server error."
#define ERROR_USER_UNLOGGED_MESSAGE                     @"No user logged in."
#define ERROR_INVALID_USERNAME_OR_PASSWORD_MESSAGE      @"Invalid username or password."
#define ERROR_INVALID_COORDINATES_MESSAGE               @"Invalid coordinates value."
#define ERROR_INVALID_RANGE_MESSAGE                     @"Invalid range value."
#define ERROR_USERNAME_NOT_EXISTS_MESSAGE               @"Username does not exists."
#define ERROR_INVALID_USERNAME_MESSAGE                  @"Invalid username."
#define ERROR_INVALID_PASSWORD_MESSAGE                  @"Invalid Password."
#define ERROR_INVALID_EMAIL_MESSAGE                     @"Invalid email."
#define ERROR_PASSWORD_NOT_MATCH_MESSAGE                @"Password fields does not match."
#define ERROR_PASSWORD_LENGTH_MESSAGE                   @"Password less than 4 letters."
#define ERROR_USERNAME_EXISTS_MESSAGE                   @"Username already exists."
#define ERROR_EMAIL_EXISTS_MESSAGE                      @"E-mail already exists."

typedef enum{
    NO_ERROR = 0,
    ERROR_SERVER_NOT_RESPOND = 1,
    ERROR_USER_CANCEL = 2,
    ERROR_SQL_CONNECT = 5,
    ERROR_SQL_SERVER = 6,
    ERROR_USER_UNLOGGED = 9,
    ERROR_INVALID_USERNAME_OR_PASSWORD = 11,
    ERROR_INVALID_COORDINATES = 31,
    ERROR_INVALID_RANGE = 41,
    ERROR_USERNAME_NOT_EXISTS = 51,
    ERROR_INVALID_USERNAME = 61,
    ERROR_INVALID_PASSWORD = 62,
    ERROR_INVALID_EMAIL = 63,
    ERROR_PASSWORD_LENGTH = 64,
    ERROR_USERNAME_EXISTS = 65,
    ERROR_EMAIL_EXISTS = 66,
    ERROR_PASSWORD_NOT_MATCH = 67,
    ERROR_NO_GPS = 101,
    ERROR_NO_NETWORK = 102,
    ERROR_NO_SERVER = 103
}ServerErrors;


typedef enum{
    ACCOUNT_VIEW_SIGNUP = 1,
    ACCOUNT_VIEW_EDIT_USER = 2
} AccountViewOptions;

typedef enum{
    DIRECTION_ERROR = 0,
    DIRECTION_NORTH = 1,
    DIRECTION_SOUTH = 2,
    DIRECTION_WEST = 3,
    DIRECTION_EAST = 4
} LocationDirection;

typedef enum{
    LOG_STATE_ERROR = 0,
    LOG_STATE_LOGOUT = 1,
    LOG_STATE_PENDING = 2,
    LOG_STATE_LOGIN = 3
}LogState;

typedef enum{
    LOCATION_STATE_OFF = 0,
    LOCATION_STATE_ON = 1,
    LOCATION_STATE_STATION = 2
}LocationState;

typedef enum{
    APPMANAGER_NONE_NOTIFICATION = 0,
    APPMANAGER_LOG_NOTIFICATION = 1,
    APPMANAGER_NET_NOTIFICATION = 2,
    APPMANAGER_GPS_NOTIFICATION = 3,
    APPMANAGER_LOCATION_NOTIFICATION = 4,
    APPMANAGER_NEIGHBOURS_NOTIFICATION = 5,
    APPMANAGER_SERVER_NOTIFICATION = 6,
    APPMANAGER_LOC_NOTIFICATION = 7
}AppManagerNotification;

typedef enum{
    MAP_TYPE_MAP = 0,
    MAP_TYPE_HYBRID = 1,
    MAP_TYPE_SATELITE = 2
}MapType;


#endif

//
//  AirportRL.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "RLMObject.h"

@interface AirportRL : RLMObject

@property NSString* iata;
@property NSString* name;
@property NSString* city;
@property NSString* countryName;
@property NSString* regionName;
@property NSString* timezoneRegionName;
@property CGFloat latitude;
@property CGFloat longitude;
@property CGFloat elevation;

@end

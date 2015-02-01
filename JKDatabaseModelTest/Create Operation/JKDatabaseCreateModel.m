//
//  JKDatabaseCreateModel.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKDatabaseCreateModel.h"
#import "Airlines.h"
#import "AirlineRL.h"

#import "Airport.h"
#import "AirportRL.h"

@implementation JKDatabaseCreateModel

+(void)storeAirlinesInCoreDatabaseWithCollection:(NSArray *)airlinesCollection {
    for(NSDictionary* individualObject in airlinesCollection) {
        Airlines* airlineObject = [Airlines MR_createEntity];
        airlineObject.name = individualObject[@"name"];
        airlineObject.iata = individualObject[@"iata"];
        airlineObject.fs = individualObject[@"fs"];
        airlineObject.icao = individualObject[@"icao"];
        airlineObject.active = individualObject[@"active"];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+(void)storeAirlinesInRealmDatabaseWithCollection:(NSArray *)airlinesCollection {
    NSMutableArray* realmModelsCollection = [NSMutableArray new];
    RLMRealm* realm = [RLMRealm defaultRealm];
    
    for(NSDictionary* individualObject in airlinesCollection) {
        AirlineRL* airlineObject = [[AirlineRL alloc] init];
        airlineObject.name = individualObject[@"name"];
        airlineObject.iata = individualObject[@"iata"] ? : @"";
        airlineObject.fs = individualObject[@"fs"];
        airlineObject.icao = individualObject[@"icao"] ? : @"";
        airlineObject.active = [individualObject[@"active"] boolValue] ? @"1" : @"0";
        [realmModelsCollection addObject:airlineObject];
    }
    
    [realm beginWriteTransaction];
    [realm addObjects:realmModelsCollection];
    [realm commitWriteTransaction];
}

+(void)storeAirportsInCoreDatabaseWithCollection:(NSArray*)airportsCollection {
    for(NSDictionary* individualObject in airportsCollection) {
        Airport* airportObject = [Airport MR_createEntity];
        airportObject.iata = individualObject[@"iata"];
        airportObject.name = individualObject[@"name"];
        airportObject.city = individualObject[@"city"];
        airportObject.countryName = individualObject[@"countryName"];
        airportObject.regionName = individualObject[@"regionName"];
        airportObject.timezoneRegionName = individualObject[@"timeZoneRegionName"];
        airportObject.latitude = individualObject[@"latitude"];
        airportObject.longitude = individualObject[@"longitude"];
        airportObject.elevation = individualObject[@"elevationFeet"];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    
}

+(void)storeAirportsInRealmDatabaseWithCollection:(NSArray*)airportsCollection {
    NSMutableArray* realmModelsCollection = [NSMutableArray new];
    RLMRealm* realm = [RLMRealm defaultRealm];
    
    for(NSDictionary* individualObject in airportsCollection) {
        AirportRL* airportObject = [[AirportRL alloc] init];
        airportObject.iata = individualObject[@"iata"] ? : @"";
        airportObject.name = individualObject[@"name"];
        airportObject.city = individualObject[@"city"];
        airportObject.countryName = individualObject[@"countryName"];
        airportObject.regionName = individualObject[@"regionName"];
        airportObject.timezoneRegionName = individualObject[@"timeZoneRegionName"];
        airportObject.latitude = individualObject[@"latitude"]? [individualObject[@"latitude"] floatValue] : 0;
        airportObject.longitude = individualObject[@"longitude"]? [individualObject[@"longitude"] floatValue] : 0;
        airportObject.elevation = individualObject[@"elevationFeet"]? [individualObject[@"elevationFeet"] floatValue] : 0;
        [realmModelsCollection addObject:airportObject];
    }
    
    [realm beginWriteTransaction];
    [realm addObjects:realmModelsCollection];
    [realm commitWriteTransaction];
    
}

@end

//
//  JKDatabaseSpeedTest.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKDatabaseSpeedTest.h"
#import "Airlines.h"
#import "AirlineRL.h"
#import "Airport.h"
#import "AirportRL.h"

@implementation JKDatabaseSpeedTest

+(void)beginTestingOperationForAirlinesDatabase {
    
    NSDate* methodStart = [NSDate date];
    RLMRealm* realm = [RLMRealm defaultRealm];
    
    //READ Operation time of execution
    NSArray* allObjectsFromCoreData = [Airlines MR_findAll];
    NSInteger totalNumberOfRecordsFromCoreData = (long)[allObjectsFromCoreData count];
    DLog(@"Execution time to get all Core Data objects for Airlines %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromCoreData);
    
    methodStart = [NSDate date];
    RLMResults* allObjectsFromRealm = [AirlineRL allObjects];
    NSInteger totalNumberOfRecordsFromRealm = (long)[allObjectsFromRealm count];
    
    DLog(@"Execution time to get Realm objects for Airlines is %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromRealm);
    
    methodStart = [NSDate date];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"active = '1'"];
    RLMResults *storedAirlines = [AirlineRL objectsWithPredicate:pred];
    DLog(@"Execution time to get Realm data from Airlines model with custom predicate %f with %ld objects retrieved", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[storedAirlines count]);
    
    methodStart = [NSDate date];
    NSArray* matchingAirlineObjects = [Airlines MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"active = 1"]];
    DLog(@"Execution time to get Core Data from Airlines collection custom predicate %f and number of retrieved records is %ld", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirlineObjects count]);
    
    //DELETE Operation time of execution
    methodStart = [NSDate date];
    [realm beginWriteTransaction];
    [realm deleteObjects:[AirlineRL allObjects]];
    [realm commitWriteTransaction];
    DLog(@"Execution time to delete all records for Airlines model from Realm data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromRealm);
    
    methodStart = [NSDate date];
    [Airlines MR_truncateAll];
    DLog(@"Execution time to delete all records from Core data model for Airlines model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromCoreData);
    
    //Saving core data context in persistent format - Just to be safe.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+(void)beginTestingOperationForAirportsDatabase {
    
    NSDate* methodStart = [NSDate date];
    RLMRealm* realm = [RLMRealm defaultRealm];
    
    //READ Operation time of execution
    NSArray* allObjectsFromCoreData = [Airport MR_findAll];
    NSInteger totalNumberOfRecordsFromCoreData = (long)[allObjectsFromCoreData count];
    DLog(@"Execution time to get all Core Data objects for Airports %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromCoreData);
    
    methodStart = [NSDate date];
    RLMResults* allObjectsFromRealm = [AirportRL allObjects];
    NSInteger totalNumberOfRecordsFromRealm = (long)[allObjectsFromRealm count];
    
    DLog(@"Execution time to get Realm objects for Airports is %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromRealm);
    
    methodStart = [NSDate date];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"iata = ''"];
    RLMResults *storedAirports = [AirportRL objectsWithPredicate:pred];
    DLog(@"Execution time to get Realm data from Airport model with custom predicate %f with %ld objects retrieved", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[storedAirports count]);
    
    methodStart = [NSDate date];
    NSArray* matchingAirportObjects = [Airport MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(iata == nil) OR (iata == '')"]];
    DLog(@"Execution time to get Core Data from Airport collection custom predicate %f and number of retrieved records is %ld", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirportObjects count]);
    
    //DELETE Operation time of execution
    methodStart = [NSDate date];
    [realm beginWriteTransaction];
    [realm deleteObjects:[AirportRL allObjects]];
    [realm commitWriteTransaction];
    DLog(@"Execution time to delete all records for Airport model from Realm data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromRealm);
    
    methodStart = [NSDate date];
    [Airport MR_truncateAll];
    DLog(@"Execution time to delete all records from Core data model for Airport model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromCoreData);
    
    //Saving core data context in persistent format - Just to be safe.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end

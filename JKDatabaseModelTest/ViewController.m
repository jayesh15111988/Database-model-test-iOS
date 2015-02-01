//
//  ViewController.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "ViewController.h"
#import "AirlineRL.h"
#import "Airlines.h"

#define RECORDS_INCREMENT_PARAMETER 10

@interface ViewController ()
@property (nonatomic, strong) AFHTTPRequestOperationManager* manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[AFHTTPRequestOperationManager alloc]
               initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, API_EXTENSION]]];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if([[AirlineRL allObjects] count] == 0) {
        [self fetchAndStoreDataInDatabase];
    }
}

-(void)beginTestingOperation {
    NSDate* methodStart = [NSDate date];
    NSArray* allObjectsFromCoreData = [Airlines MR_findAll];
    DLog(@"Execution time to get all core data objects %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[allObjectsFromCoreData count]);
    methodStart = [NSDate date];
    RLMResults* allObjectsFromRealm = [AirlineRL allObjects];
    DLog(@"Execution time to get realm objects is %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[allObjectsFromRealm count]);
    methodStart = [NSDate date];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"active = '1'"];
    RLMResults *storedAirlines = [AirlineRL objectsWithPredicate:pred];
    
    DLog(@"Execution time to get realm data with custom predicate %f with %ld objects retrieved", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[storedAirlines count]);
    methodStart = [NSDate date];
    RLMRealm* defaultRealm = [RLMRealm defaultRealm];
    
    for (AirlineRL* individualAirlineObject in storedAirlines) {
        if(individualAirlineObject.iata.length == 0) {
            [defaultRealm beginWriteTransaction];
            individualAirlineObject.iata = @"IATA";
            [defaultRealm commitWriteTransaction];
        }
        if(individualAirlineObject.icao.length == 0) {
            [defaultRealm beginWriteTransaction];
            individualAirlineObject.icao = @"ICAO";
            [defaultRealm commitWriteTransaction];
        }
    }
    DLog(@"Execution time to update realm data is %f with %ld number of updated records", [[NSDate date] timeIntervalSinceDate:methodStart], (long) [storedAirlines count]);
    methodStart = [NSDate date];
    
    NSArray* matchingAirlineObjects = [Airlines MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"active = 1"]];
    DLog(@"Execution time to get core data with custom predicate %f and number of retrieved records is %ld", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirlineObjects count]);
    methodStart = [NSDate date];
    for (Airlines* individualAirlineObject in matchingAirlineObjects) {
        if(individualAirlineObject.iata.length == 0) {
            individualAirlineObject.iata = @"IATA";
        }
        if(individualAirlineObject.icao.length == 0) {
            individualAirlineObject.icao = @"ICAO";
        }
    }
    
    DLog(@"Execution time to update Core data is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirlineObjects count]);
    methodStart = [NSDate date];
    
    [defaultRealm beginWriteTransaction];
    [defaultRealm deleteObjects:[AirlineRL allObjects]];
    [defaultRealm commitWriteTransaction];
    
    DLog(@"Execution time to delete all records from Realm data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long) [allObjectsFromRealm count]);
    methodStart = [NSDate date];
    
    [Airlines MR_truncateAll];
    
    DLog(@"**Execution time to delete all records from Core data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[allObjectsFromCoreData count]);
    methodStart = [NSDate date];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


-(void)fetchAndStoreDataInDatabase {
    
    __block NSDate *methodStart = [NSDate date];
    
    [[self.manager rac_GET:[NSString stringWithFormat:@"airlines/rest/v1/json/all"] parameters:@{@"appId" : APP_ID, @"appKey" : APP_KEY}] subscribeNext:^(RACTuple* tuple) {
        RACTupleUnpack(AFHTTPRequestOperation *operation, NSDictionary *response) = tuple;
        DLog(@"Execution time to get network data %f", [[NSDate date] timeIntervalSinceDate:methodStart]);
        methodStart = [NSDate date];
        [self storeDataInCoreDataWithDictionary:response[@"airlines"]];
        DLog(@"Time to store data by Core data %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[response[@"airlines"] count] * RECORDS_INCREMENT_PARAMETER);
        methodStart = [NSDate date];
        [self storeDataInRealmWithDictionary:response[@"airlines"]];
        DLog(@"Time to store data by Realm data model %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart],(long)[response[@"airlines"] count] * RECORDS_INCREMENT_PARAMETER);
        [self beginTestingOperation];
    }
                                                                                                                    error:^(NSError *error) {
                                                                                                                        AFHTTPRequestOperation *operation = [error.userInfo objectForKey:@"AFHTTPRequestOperation"];
                                                                                                                        DLog(@"error: operation=%@", operation);
                                                                                                                                             }
                                                                                                                                         completed:^{
                                                                                                                                             DLog(@"Network Operation Completed");
                                                                                                                                         }];

}


-(void)storeDataInRealmWithDictionary:(NSArray*)responseData{
    
    NSMutableArray* realmModelsCollection = [NSMutableArray new];
    
    for(NSInteger i = 0; i < RECORDS_INCREMENT_PARAMETER; i++) {
        for(NSDictionary* individualObject in responseData) {
            AirlineRL* airlineObject = [[AirlineRL alloc] init];
            airlineObject.name = individualObject[@"name"];
            airlineObject.iata = individualObject[@"iata"] ? : @"";
            airlineObject.fs = individualObject[@"fs"];
            airlineObject.icao = individualObject[@"icao"] ? : @"";
            airlineObject.active = [individualObject[@"active"] boolValue] ? @"1" : @"0";
            [realmModelsCollection addObject:airlineObject];
        }
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObjects:realmModelsCollection];
    [realm commitWriteTransaction];
}

-(void)storeDataInCoreDataWithDictionary:(NSArray*) responseData {
    
    for(NSInteger i = 0; i < RECORDS_INCREMENT_PARAMETER; i++) {
        for(NSDictionary* individualObject in responseData) {
            Airlines* airlineObject = [Airlines MR_createEntity];
            airlineObject.name = individualObject[@"name"];
            airlineObject.iata = individualObject[@"iata"];
            airlineObject.fs = individualObject[@"fs"];
            airlineObject.icao = individualObject[@"icao"];
            airlineObject.active = individualObject[@"active"];
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


@end

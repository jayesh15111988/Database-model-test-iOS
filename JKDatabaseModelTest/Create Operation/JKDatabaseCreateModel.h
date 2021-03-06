//
//  JKDatabaseCreateModel.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKDatabaseCreateModel : NSObject

+(void)storeAirlinesInCoreDatabaseWithCollection:(NSArray*)airlinesCollection;
+(void)storeAirlinesInRealmDatabaseWithCollection:(NSArray*)airlinesCollection;

+(void)storeAirportsInCoreDatabaseWithCollection:(NSArray*)airportsCollection;
+(void)storeAirportsInRealmDatabaseWithCollection:(NSArray*)airportsCollection;

@end

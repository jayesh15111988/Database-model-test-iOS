//
//  Airlines.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Airlines : NSManagedObject

@property (nonatomic, retain) NSNumber* active;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* iata;
@property (nonatomic, retain) NSString* icao;
@property (nonatomic, retain) NSString* fs;

@end

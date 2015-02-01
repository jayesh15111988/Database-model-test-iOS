//
//  Airport.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Airport : NSManagedObject

@property (nonatomic, retain) NSString* iata;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* countryName;
@property (nonatomic, retain) NSString* regionName;
@property (nonatomic, retain) NSString* timezoneRegionName;
@property (nonatomic, retain) NSNumber* latitude;
@property (nonatomic, retain) NSNumber* longitude;
@property (nonatomic, retain) NSNumber* elevation;

@end

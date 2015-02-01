//
//  ReleasedApp.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "RLMObject.h"

@interface ReleasedApp : RLMObject

@property NSString* appName;
@property NSString* cost;
@property NSString* platform;

@end

RLM_ARRAY_TYPE(ReleasedApp)

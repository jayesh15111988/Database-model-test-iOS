//
//  Developer.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "RLMObject.h"
#import "ReleasedApp.h"

@interface Developer : RLMObject

@property NSString* name;
@property NSString* platform;
@property NSString* experience;
@property NSString* state;

@property RLMArray<ReleasedApp> *releasedAppsCollection;
@end
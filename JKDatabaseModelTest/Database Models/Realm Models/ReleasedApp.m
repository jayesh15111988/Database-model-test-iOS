//
//  ReleasedApp.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "ReleasedApp.h"
#import "Developer.h"

@implementation ReleasedApp

+(RACSignal*)addApplicationWithInputParameters:(NSArray*)inputParameters {
    
    NSString* returnMessage = @"";
    RLMRealm* defaultRealm = [RLMRealm defaultRealm];
    
    RLMResults* developerWithCurrentName = [Developer objectsWhere:@"name = %@",inputParameters[0]];
    if([developerWithCurrentName count] > 0) {
        
        Developer* developerWithGivenName = [developerWithCurrentName firstObject];
        
        [defaultRealm beginWriteTransaction];
        ReleasedApp* newAppToAdd = [[ReleasedApp alloc] init];
        newAppToAdd.appName = inputParameters[1];
        newAppToAdd.cost = inputParameters[2];
        newAppToAdd.platform = inputParameters[3];
        [developerWithGivenName.releasedAppsCollection addObject:newAppToAdd];
        [defaultRealm commitWriteTransaction];
        returnMessage =  @"Application Successfully added to Model";
    }
    else {
        returnMessage = @"No developer with such name exists in Database";
    }
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:returnMessage];
        [subscriber sendCompleted];
        return nil;
    }];
}


@end

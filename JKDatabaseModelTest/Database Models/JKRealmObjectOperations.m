//
//  JKRealmObjectOperations.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKRealmObjectOperations.h"
#import "Developer.h"
#import "ReleasedApp.h"

@implementation JKRealmObjectOperations

+(RACSignal*)addDeveloperWithParameters:(NSArray*)inputCollection {
    RLMRealm* defaultRealm = [RLMRealm defaultRealm];
    
    NSString* returnMessageString = @"";
    
    RLMResults* developerWithCurrentName = [Developer objectsWhere:@"name = %@",inputCollection[0]];
    
    //Add it only another developer with same name does not exist in the database
    if([developerWithCurrentName count] == 0) {
        Developer* developerObject = [[Developer alloc] init];
        developerObject.name = inputCollection[0];
        developerObject.platform = inputCollection[1];
        developerObject.state = inputCollection[2];
        developerObject.experience = inputCollection[3];
        [defaultRealm beginWriteTransaction];
        [defaultRealm addObject:developerObject];
        [defaultRealm commitWriteTransaction];
        returnMessageString = @"Developer Successfully added to model";
    }
    else {
        returnMessageString = @"Developer with this name already exists in the database. Please try some other name";
    }
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:returnMessageString];
        [subscriber sendCompleted];
        return nil;
    }];
}

+(RACSignal*)addApplicationWithInputParameters:(NSArray*)inputParameters {
    
    NSString* returnMessage = @"";
    RLMRealm* defaultRealm = [RLMRealm defaultRealm];
    
    RLMResults* developerWithCurrentName = [Developer objectsWhere:@"name = %@",inputParameters[0]];
    if([developerWithCurrentName count] > 0) {
        
        Developer* developerWithGivenName = [developerWithCurrentName firstObject];
        ReleasedApp* newAppToAdd = [[ReleasedApp alloc] init];
        newAppToAdd.appName = inputParameters[1];
        newAppToAdd.cost = inputParameters[2];
        newAppToAdd.platform = inputParameters[3];
        [defaultRealm beginWriteTransaction];
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

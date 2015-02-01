//
//  Developer.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "Developer.h"

@implementation Developer

+(RACSignal*)addDeveloperWithParameters:(NSArray*)inputCollection {
    RLMRealm* defaultRealm = [RLMRealm defaultRealm];
    
    NSString* returnMessageString = @"";
    
    RLMResults* developerWithCurrentName = [Developer objectsWhere:@"name = %@",inputCollection[0]];
    
    //Add it only another developer with same name does not exist in the database
    if([developerWithCurrentName count] == 0) {
        [defaultRealm beginWriteTransaction];
        Developer* developerObject = [[Developer alloc] init];
        developerObject.name = inputCollection[0];
        developerObject.platform = inputCollection[1];
        developerObject.state = inputCollection[2];
        developerObject.experience = inputCollection[3];
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


@end

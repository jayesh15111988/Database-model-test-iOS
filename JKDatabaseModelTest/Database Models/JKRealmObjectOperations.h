//
//  JKRealmObjectOperations.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 2/1/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKRealmObjectOperations : NSObject
+(RACSignal*)addDeveloperWithParameters:(NSArray*)inputCollection;
+(RACSignal*)addApplicationWithInputParameters:(NSArray*)inputParameters;
@end

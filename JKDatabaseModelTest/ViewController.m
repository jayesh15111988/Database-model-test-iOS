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
#import "ApplicationDetailsTableViewCell.h"
#import "ReleasedApp.h"
#import "Developer.h"

#define RECORDS_INCREMENT_PARAMETER 10

@interface ViewController ()
@property (nonatomic, strong) AFHTTPRequestOperationManager* manager;
@property (nonatomic, strong) RLMResults* developersCollection;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *footerForTableView;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *platform;
@property (weak, nonatomic) IBOutlet UITextField *experience;
@property (weak, nonatomic) IBOutlet UITextField *extraInfo;
@property (weak, nonatomic) IBOutlet UIButton *switchInputModeButton;
@property (weak, nonatomic) IBOutlet UIButton *addObjectButton;

@property (assign, nonatomic) BOOL isAddingApp;

@property (weak, nonatomic) IBOutlet UIView *addDeveloperView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSignals];
    self.tableView.tableFooterView = self.footerForTableView;
    
    self.manager = [[AFHTTPRequestOperationManager alloc]
               initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, API_EXTENSION]]];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if([[AirlineRL allObjects] count] == 0) {
        [self fetchAndStoreDataInDatabase];
    }
    else {
        [self loadAppsCollectionTable];
    }
    
    self.isAddingApp = YES;
    [self updateInputInfoViewWithAddingAppFlag];
}

-(void)updateInputInfoViewWithAddingAppFlag {
    [self.addObjectButton setTitle:self.isAddingApp ? @"Add App" : @"Add Developer" forState:UIControlStateNormal];
    
    if(self.isAddingApp) {
        self.platform.placeholder = @"App Name";
        self.experience.placeholder = @"Platform";
        self.extraInfo.placeholder = @"Cost";
        [self.addObjectButton setTitle:@"Add App" forState:UIControlStateNormal];
    }
    else {
        [self.addObjectButton setTitle: @"Add Developer" forState:UIControlStateNormal];
        self.platform.placeholder = @"Platform";
        self.experience.placeholder = @"Experience";
        self.extraInfo.placeholder = @"State";
    }
}


-(void)setupSignals {
    
    self.switchInputModeButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        self.isAddingApp = !self.isAddingApp;
        [self updateInputInfoViewWithAddingAppFlag];
        return [RACSignal empty];
    }];
    
    
    RACSignal *validNameSignal =
    [self.name.rac_textSignal
     map:^id(NSString *text) {
         return @(text.length > 2);
     }];
    
    RACSignal *validPlatformSignal =
    [self.platform.rac_textSignal
     map:^id(NSString *text) {
         return @(text.length > 2);
     }];
    
    RACSignal *validThirdFieldSignal =
    [self.experience.rac_textSignal
     map:^id(NSString *text) {
         return @(text.length > 2);
     }];
    
    RACSignal *validFourthFieldSignal =
    [self.extraInfo.rac_textSignal
     map:^id(NSString *text) {
         return @(text.length > 2);
     }];
    
    RACSignal *addObjectActiveSignal =
    [RACSignal combineLatest:@[validNameSignal, validPlatformSignal, validThirdFieldSignal, validFourthFieldSignal]
                      reduce:^id(NSNumber *name, NSNumber *platform, NSNumber* thirdField, NSNumber* fourthField) {
                          return @([name boolValue] && [platform boolValue] && [thirdField boolValue] && [fourthField boolValue]);
                      }];
    
    [addObjectActiveSignal subscribeNext:^(NSNumber *addObjectActive) {
        self.addObjectButton.userInteractionEnabled = [addObjectActive boolValue];
        self.addObjectButton.alpha = [addObjectActive boolValue] ? 1 : 0.3;
    }];
    
    
    self.addObjectButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        DLog(@"Add Object Button Pressed");
        if(self.isAddingApp) {
            //Add App object
            [self addApplicaiton];
        }
        else {
            //Add Developer object
            [self addDeveloper];
        }
        [self loadAppsCollectionTable];
        return [RACSignal empty];
    }];
    
}

-(void)addDeveloper {
    
    RLMRealm* defaultRealm = [RLMRealm defaultRealm];
    [defaultRealm beginWriteTransaction];
    Developer* developerObject = [[Developer alloc] init];
    developerObject.name = self.name.text;
    developerObject.platform = self.platform.text;
    developerObject.state = self.extraInfo.text;
    developerObject.experience = self.experience.text;
    [defaultRealm addObject:developerObject];
    [defaultRealm commitWriteTransaction];
}

-(void)addApplicaiton {
    
    RLMResults* developerWithCurrentName = [Developer objectsWhere:@"name = %@",self.name.text];
    if([developerWithCurrentName count] > 0) {
        
        RLMRealm* defaultRelam = [RLMRealm defaultRealm];
        
        Developer* developerWithGivenName = [developerWithCurrentName firstObject];
        
        [defaultRelam beginWriteTransaction];
        ReleasedApp* newAppToAdd = [[ReleasedApp alloc] init];
        newAppToAdd.appName = self.name.text;
        newAppToAdd.cost = self.extraInfo.text;
        newAppToAdd.platform = self.platform.text;
        [developerWithGivenName.releasedAppsCollection addObject:newAppToAdd];
        [defaultRelam commitWriteTransaction];
    }
    else {
        [self showMessageWithBody:@"No developer with such name exists in database"];
    }
}

-(void)showMessageWithBody:(NSString*)messageBody {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Realm Demo"
                                                        message:messageBody delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alertView show];
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
    
    //Following commented block is used to delete all objects from database. Commenting for now
  /*  DLog(@"Execution time to update Core data is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirlineObjects count]);
    methodStart = [NSDate date];
    
    [defaultRealm beginWriteTransaction];
    [defaultRealm deleteObjects:[AirlineRL allObjects]];
    [defaultRealm commitWriteTransaction];
    
    DLog(@"Execution time to delete all records from Realm data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long) [allObjectsFromRealm count]);
    methodStart = [NSDate date];
    
    [Airlines MR_truncateAll];
    
    DLog(@"**Execution time to delete all records from Core data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[allObjectsFromCoreData count]);
    methodStart = [NSDate date];
    */
    
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
        [self loadAppsCollectionTable];
    }
                                                                                                                    error:^(NSError *error) {
                                                                                                                        AFHTTPRequestOperation *operation = [error.userInfo objectForKey:@"AFHTTPRequestOperation"];
                                                                                                                        DLog(@"error: operation=%@", operation);
                                                                                                                                             }
                                                                                                                                         completed:^{
                                                                                                                                             DLog(@"Network Operation Completed");
                                                                                                                                         }];

}

-(void)loadAppsCollectionTable {
    self.developersCollection = [Developer allObjects];
    [self.tableView reloadData];
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

#pragma tableView datasource and delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Developer* developerForCurrentSection = self.developersCollection[section];
    return [developerForCurrentSection.releasedAppsCollection count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.developersCollection count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ApplicationDetailsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"appdetailcell" forIndexPath:indexPath];
    Developer* currentDeveloper = self.developersCollection[indexPath.section];
    ReleasedApp* currentApp = currentDeveloper.releasedAppsCollection[indexPath.row];
    cell.appName.text = [NSString stringWithFormat:@"App : %@",currentApp.appName];
    cell.platform.text = [NSString stringWithFormat:@"Platform : %@",currentApp.platform];
    cell.cost.text = [NSString stringWithFormat:@"Cost : %@",currentApp.cost];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    Developer* currentDeveloper = self.developersCollection[section];
    
    UIView* customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [customHeaderView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* developerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 130, 20)];
    developerNameLabel.textAlignment = NSTextAlignmentCenter;
    developerNameLabel.text = [NSString stringWithFormat:@"Name : %@",currentDeveloper.name];
    
    UILabel* stateNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 20, 130, 20)];
    stateNameLabel.textAlignment = NSTextAlignmentCenter;
    stateNameLabel.text = [NSString stringWithFormat:@"State : %@", currentDeveloper.state];
    
    [customHeaderView addSubview:developerNameLabel];
    [customHeaderView addSubview:stateNameLabel];
    
    customHeaderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    customHeaderView.layer.borderWidth = 1.0f;
    
    return customHeaderView;
}


@end

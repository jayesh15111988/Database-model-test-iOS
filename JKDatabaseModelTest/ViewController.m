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
#import <UIView+BlocksKit.h>
#import <UIAlertView+BlocksKit.h>

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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *addDeveloperView;

@property (weak, nonatomic) IBOutlet UIView *noResultView;
@property (retain, nonatomic) RLMRealm* defaultRealm;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSignals];
    self.defaultRealm = [RLMRealm defaultRealm];
    self.tableView.tableFooterView = self.footerForTableView;
    [self addBorderToView:self.tableView];
    [self addBorderToView:self.addDeveloperView];
    
    self.manager = [[AFHTTPRequestOperationManager alloc]
               initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, API_EXTENSION]]];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if([[AirlineRL allObjects] count] == 0) {
        [self.activityIndicator startAnimating];
        [self fetchAndStoreDataInDatabase];
    }
    else {
        //[self beginTestingOperation];
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
    
    
    [self.defaultRealm beginWriteTransaction];
    Developer* developerObject = [[Developer alloc] init];
    developerObject.name = self.name.text;
    developerObject.platform = self.platform.text;
    developerObject.state = self.extraInfo.text;
    developerObject.experience = self.experience.text;
    [self.defaultRealm addObject:developerObject];
    [self.defaultRealm commitWriteTransaction];
    
    [self showMessageWithBody:@"Developer Successfully added to model"];
}

-(void)addApplicaiton {
    
    RLMResults* developerWithCurrentName = [Developer objectsWhere:@"name = %@",self.name.text];
    if([developerWithCurrentName count] > 0) {
        
        Developer* developerWithGivenName = [developerWithCurrentName firstObject];
        
        [self.defaultRealm beginWriteTransaction];
        ReleasedApp* newAppToAdd = [[ReleasedApp alloc] init];
        newAppToAdd.appName = self.name.text;
        newAppToAdd.cost = self.extraInfo.text;
        newAppToAdd.platform = self.platform.text;
        [developerWithGivenName.releasedAppsCollection addObject:newAppToAdd];
        [self.defaultRealm commitWriteTransaction];
        [self showMessageWithBody:@"Application Successfully added to model"];
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
    RLMRealm* realm = [RLMRealm defaultRealm];
    
    //READ Operation time of execution
    NSArray* allObjectsFromCoreData = [Airlines MR_findAll];
    NSInteger totalNumberOfRecordsFromCoreData = (long)[allObjectsFromCoreData count];
    DLog(@"Execution time to get all Core Data objects %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromCoreData);
    
    methodStart = [NSDate date];
    RLMResults* allObjectsFromRealm = [AirlineRL allObjects];
    NSInteger totalNumberOfRecordsFromRealm = (long)[allObjectsFromRealm count];
    
    DLog(@"Execution time to get Realm objects is %f for %ld objects", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromRealm);
    
    //UPDATE Operation time of execution
    methodStart = [NSDate date];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"active = '1'"];
    RLMResults *storedAirlines = [AirlineRL objectsWithPredicate:pred];
    DLog(@"Execution time to get Realm data with custom predicate %f with %ld objects retrieved", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[storedAirlines count]);
    
    methodStart = [NSDate date];

    for (AirlineRL* individualAirlineObject in storedAirlines) {
        if(individualAirlineObject.iata.length == 0) {
            [realm beginWriteTransaction];
            individualAirlineObject.iata = @"IATA";
            [realm commitWriteTransaction];
        }
        if(individualAirlineObject.icao.length == 0) {
            [realm beginWriteTransaction];
            individualAirlineObject.icao = @"ICAO";
            [realm commitWriteTransaction];
        }
    }
    DLog(@"Execution time to update realm data is %f with %ld number of updated records", [[NSDate date] timeIntervalSinceDate:methodStart], (long) [storedAirlines count]);
    
    methodStart = [NSDate date];
    NSArray* matchingAirlineObjects = [Airlines MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"active = 1"]];
    DLog(@"Execution time to get Core Data with custom predicate %f and number of retrieved records is %ld", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirlineObjects count]);
    
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
    DLog(@"Execution time to update Core data is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], (long)[matchingAirlineObjects count]);
    
    //DELETE Operation time of execution
    methodStart = [NSDate date];
    [realm beginWriteTransaction];
    [realm deleteObjects:[AirlineRL allObjects]];
    [realm commitWriteTransaction];
    DLog(@"Execution time to delete all records from Realm data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromRealm);
    
    methodStart = [NSDate date];
    [Airlines MR_truncateAll];
    DLog(@"Execution time to delete all records from Core data model is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], totalNumberOfRecordsFromCoreData);
    
    //Saving core data context in persistent format - Just to be safe.
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

-(void)fetchAndStoreDataInDatabase {
    
    __block NSDate *methodStart = [NSDate date];
    
    [[self.manager rac_GET:[NSString stringWithFormat:@"airlines/rest/v1/json/all"] parameters:@{@"appId" : APP_ID, @"appKey" : APP_KEY}] subscribeNext:^(RACTuple* tuple) {
        
        //Perform database storage on the background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        RACTupleUnpack(AFHTTPRequestOperation *operation, NSDictionary *response) = tuple;
        DLog(@"Execution time to get network data %f", [[NSDate date] timeIntervalSinceDate:methodStart]);
            
        //CREATE Operation time of execution
        methodStart = [NSDate date];
        NSInteger numberOfRecords = (long)[response[@"airlines"] count];
        [self storeDataInCoreDataWithDictionary:response[@"airlines"]];
        DLog(@"Time to store data by Core Data %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], numberOfRecords * RECORDS_INCREMENT_PARAMETER);
        methodStart = [NSDate date];
        [self storeDataInRealmWithDictionary:response[@"airlines"]];
        DLog(@"Time to store data by Realm is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], numberOfRecords * RECORDS_INCREMENT_PARAMETER);
            
        //We will performa testing and compare Realm with Core data viz. Magical Records in terms of performance for READ, DELETE and UPDATE operation
        [self beginTestingOperation];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self loadAppsCollectionTable];
            [self.activityIndicator stopAnimating];
        });
        });
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
    self.noResultView.hidden = (self.developersCollection.count > 0);
    [self.tableView reloadData];
}


-(void)storeDataInRealmWithDictionary:(NSArray*)responseData{
    
    NSMutableArray* realmModelsCollection = [NSMutableArray new];
    RLMRealm* realm = [RLMRealm defaultRealm];
    
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
    
    UIFont* defaultFontForLabel = [UIFont systemFontOfSize:12];
    
    UIView* customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [customHeaderView setBackgroundColor:[UIColor greenColor]];
    
    UILabel* developerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 130, 20)];
    developerNameLabel.textAlignment = NSTextAlignmentCenter;
    developerNameLabel.text = [NSString stringWithFormat:@"Name : %@",currentDeveloper.name];
    developerNameLabel.font = defaultFontForLabel;
    
    UILabel* stateNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 20, 100, 20)];
    stateNameLabel.textAlignment = NSTextAlignmentCenter;
    stateNameLabel.text = [NSString stringWithFormat:@"State : %@", currentDeveloper.state];
    stateNameLabel.font = defaultFontForLabel;
    
    UIButton* removeDeveloperButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 10, 30, 30)];
    [removeDeveloperButton setBackgroundImage:[UIImage imageNamed:@"button_minus_red.png"] forState:UIControlStateNormal];
    [removeDeveloperButton bk_whenTapped:^{
    [UIAlertView bk_showAlertViewWithTitle:@"Add Developers Program" message:@"Are you sure you want to remove this developer? All apps associated with this develoepr will also be lost" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //It's not cancel button pressed for sure
        if(buttonIndex > 0) {
            Developer* developerToDelete = self.developersCollection[section];
            [self.defaultRealm beginWriteTransaction];
            [self.defaultRealm deleteObject:developerToDelete];
            [self.defaultRealm commitWriteTransaction];
            [self loadAppsCollectionTable];
        }
    }];
    }];
    
    [customHeaderView addSubview:developerNameLabel];
    [customHeaderView addSubview:stateNameLabel];
    [customHeaderView addSubview:removeDeveloperButton];
    
    [self addBorderToView:customHeaderView];
    
    return customHeaderView;
}

-(void)addBorderToView:(UIView*)inputView {
    inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inputView.layer.borderWidth = 1.0f;
}


@end

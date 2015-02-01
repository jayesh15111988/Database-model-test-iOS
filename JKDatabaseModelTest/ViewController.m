//
//  ViewController.m
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "ViewController.h"
#import "AirlineRL.h"
#import "AirportRL.h"
#import "ApplicationDetailsTableViewCell.h"
#import "ReleasedApp.h"
#import "Developer.h"
#import "JKDatabaseCreateModel.h"
#import "JKDatabaseSpeedTest.h"
#import <UIView+BlocksKit.h>
#import <UIAlertView+BlocksKit.h>

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
        
        RACSignal* returnedSignalAfterNetworkOperation = [self fetchAndStoreDataInDatabaseWithURLString:@"airlines/rest/v1/json/all" andParameters:@{@"appId" : APP_ID, @"appKey" : APP_KEY}];
        
        [returnedSignalAfterNetworkOperation subscribeNext:^(RACTuple* tuple) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
                NSDate* methodStart = [NSDate date];
                //RACTupleUnpack(AFHTTPRequestOperation *operation, NSDictionary *response) = tuple;
                NSDictionary *response = tuple[1];
                DLog(@"Execution time to get Airlines data from network %f", [[NSDate date] timeIntervalSinceDate:methodStart]);
                
                //CREATE Operation time of execution
                methodStart = [NSDate date];
                NSInteger numberOfRecords = (long)[response[@"airlines"] count];
                [JKDatabaseCreateModel storeAirlinesInCoreDatabaseWithCollection:response[@"airlines"]];
                DLog(@"Time to store Airlines data by Core Data %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], numberOfRecords );
                methodStart = [NSDate date];
                [JKDatabaseCreateModel storeAirlinesInRealmDatabaseWithCollection:response[@"airlines"]];
                DLog(@"Time to store Airlines data by Realm is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], numberOfRecords);
                
                //We will performa testing and compare Realm with Core data viz. Magical Records in terms of performance for READ, DELETE and UPDATE operation
                [JKDatabaseSpeedTest beginTestingOperationForAirlinesDatabase];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self loadAppsCollectionTable];
                });
            });
        }];
    }
    else {
        [self.activityIndicator startAnimating];
        [self loadAppsCollectionTable];
    }
    
    [self loadAndMeasureExecutionTimeForAirportsCollection];
    self.isAddingApp = YES;
    [self updateInputInfoViewWithAddingAppFlag];
}

-(void)loadAndMeasureExecutionTimeForAirportsCollection {
    
    if([[AirportRL allObjects] count] == 0) {
    
        __block NSDate* methodStart = [NSDate date];
        RACSignal* signalAfterAirportsData = [self fetchAndStoreDataInDatabaseWithURLString:@"airports/rest/v1/json/active" andParameters:@{@"appId" : APP_ID, @"appKey" : APP_KEY}];
    
        [signalAfterAirportsData subscribeNext:^(RACTuple* tuple) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //RACTupleUnpack(AFHTTPRequestOperation *operation, NSDictionary *response) = tuple;
                NSDictionary *response = tuple[1];
                DLog(@"Execution time to get Airports data from network %f", [[NSDate date] timeIntervalSinceDate:methodStart]);
                //CREATE Operation time of execution
                methodStart = [NSDate date];
                NSInteger numberOfRecords = (long)[response[@"airports"] count];
        
                [JKDatabaseCreateModel storeAirportsInCoreDatabaseWithCollection:response[@"airports"]];
                DLog(@"Time to store Airports data in Core Data %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], numberOfRecords);
                methodStart = [NSDate date];
        
                [JKDatabaseCreateModel storeAirportsInRealmDatabaseWithCollection:response[@"airports"]];
                DLog(@"Time to store data Airports data by Realm is %f for %ld number of records", [[NSDate date] timeIntervalSinceDate:methodStart], numberOfRecords);
        
                [JKDatabaseSpeedTest beginTestingOperationForAirportsDatabase];
                DLog(@"All Operations Completed Now");
            });
        }];
    }
}

-(void)updateInputInfoViewWithAddingAppFlag {
    [self.addObjectButton setTitle:self.isAddingApp ? @"Add App" : @"Add Developer" forState:UIControlStateNormal];
    
    //Reset All fields when switching between one mode to other
    self.name.text = @"";
    self.platform.text = @"";
    self.experience.text = @"";
    self.extraInfo.text = @"";
    
    if(self.isAddingApp) {
        self.platform.placeholder = @"App Name";
        self.experience.placeholder = @"Cost";
        self.extraInfo.placeholder = @"Platform";
        [self.addObjectButton setTitle:@"Add App" forState:UIControlStateNormal];
    }
    else {
        [self.addObjectButton setTitle: @"Add Developer" forState:UIControlStateNormal];
        self.platform.placeholder = @"Platform";
        self.experience.placeholder = @"Experience (Years)";
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
         return @(text.length > 0);
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
            NSArray* inputApplicationParameters = @[self.name.text, self.platform.text, self.experience.text, self.extraInfo.text];
            [[ReleasedApp addApplicationWithInputParameters:inputApplicationParameters] subscribeNext:^(NSString* returnMessage) {
                [self showMessageWithBody:returnMessage];
            }];
        }
        else {
            //Add Developer object
            NSArray* inputDeveloperParameters = @[self.name.text, self.platform.text, self.extraInfo.text, self.experience.text];
            [[Developer addDeveloperWithParameters:inputDeveloperParameters] subscribeNext:^(NSString* returnMessage) {
                [self showMessageWithBody:returnMessage];
            }];
        }
        [self loadAppsCollectionTable];
        return [RACSignal empty];
    }];
    
}

-(void)showMessageWithBody:(NSString*)messageBody {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Realm Demo"
                                                        message:messageBody delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alertView show];
}

-(RACSignal*)fetchAndStoreDataInDatabaseWithURLString:(NSString*)urlExtension andParameters:(NSDictionary*)getParameters {
    RACSignal* networkCompletionSignal = [self.manager rac_GET:urlExtension parameters:getParameters];
    return networkCompletionSignal;
}

-(void)loadAppsCollectionTable {
    self.developersCollection = [Developer allObjects];
    self.noResultView.hidden = (self.developersCollection.count > 0);
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
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

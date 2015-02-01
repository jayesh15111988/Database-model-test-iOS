//
//  ApplicationDetailsTableViewCell.h
//  JKDatabaseModelTest
//
//  Created by Jayesh Kawli Backup on 1/31/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UILabel *platform;
@property (weak, nonatomic) IBOutlet UILabel *cost;

@end

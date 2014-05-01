//
//  MainViewController.h
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/25/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UserActivity.h"
@interface MainViewController : UIViewController

- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)helpButtonTouchDown:(id)sender;
- (IBAction)helpButtonTouchUp:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *latitude;
@property (strong, nonatomic) IBOutlet UILabel *longitude;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (retain, nonatomic) IBOutlet UILabel *timerLabel;
@property (retain, nonatomic) IBOutlet UILabel *alarmLabel;
- (IBAction)alarmSwitch:(id)sender;


//@property (strong, nonatomic) UserActivity *userData;

@end

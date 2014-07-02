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

@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UILabel *timerLabel;
@property (retain, nonatomic) IBOutlet UILabel *alarmLabel;
@property (retain, nonatomic) IBOutlet UISwitch *alarmSwitch;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *userLabel;
@property (retain, nonatomic) IBOutlet UILabel *alarmStatusLabel;

- (IBAction)alarmSwitch:(id)sender;
-(void)updateCounter:(NSTimer *)theTimer;

//@property (strong, nonatomic) UserActivity *userData;

@end

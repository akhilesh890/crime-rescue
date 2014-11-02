//
//  PatrolMainViewController.h
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 5/10/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PatrolMainViewController : UIViewController

- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)toggleLocationSwitch:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@end

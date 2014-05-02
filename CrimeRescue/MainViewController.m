//  MainViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/25/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

#define COUNTDOWN_START 9

@interface MainViewController ()

@end

@implementation MainViewController{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    UIAlertView *alert;
    NSTimer *timer;
    UserActivity *userData;
    int secondsLeft;
    PFUser *currentUser;
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ViewDidLoad");
    // NSLog(currentUser[@"firstname"]);
    [self hideLabelsAndSwitches:TRUE];
    currentUser = [PFUser currentUser];
    if (currentUser == false) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    NSLog(@"ViewDidLoad Done");
}

-(void)viewWillAppear:(BOOL)animated {
    currentUser = [PFUser currentUser];
    //   PFUser *currentUser = [PFUser currentUser];
    userData = [[UserActivity alloc] initWithStatus];
    [self hideLabelsAndSwitches:TRUE];
    self.statusLabel.text = @"Press Above";

    self.userLabel.text = [NSString stringWithFormat:@"Welcome, %@",[currentUser username]];
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    NSLog(@"%f", userData.currentAccuracy);
    NSLog(@"%@", userData.currentStatus);
    
    NSLog(@"ViewDidAppear");
    // NSLog(currentUser[@"firstname"]);
    NSLog(@"ViewDidAppear Done");
    secondsLeft = COUNTDOWN_START;
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"%d", secondsLeft);
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - Button Methods

- (IBAction)helpButtonTouchDown:(id)sender {
    //GPS Data sent.
    NSLog(@"Pressed");
    self.statusLabel.text = @"Keep Pressed Until Danger";
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    userData.currentStatus = @"ENABLED";
    
}

- (IBAction)helpButtonTouchUp:(id)sender {
    self.statusLabel.text = @"Cancel Alarm Before Timer Ends";
    NSLog(@"Released");
    userData.currentStatus = @"DISABLED";
    userData.currentAccuracy = DBL_MAX;
    secondsLeft = COUNTDOWN_START;
    self.timerLabel.text = [NSString stringWithFormat:@"%d", COUNTDOWN_START];
    [self hideLabelsAndSwitches:FALSE];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [self.alarmSwitch setOn:TRUE animated:TRUE];
    }
    if (buttonIndex == 1) {
        NSString *passwordEntered = [alert textFieldAtIndex:0].text;
        if ([passwordEntered isEqualToString:currentUser[@"passcode"]]) {
            self.statusLabel.text = @"Alarm Disabled";
            NSLog(@"Equalled");
            secondsLeft = 0;
            if (timer){
                [timer invalidate];
                timer = nil;
            }
            [alert dismissWithClickedButtonIndex:0 animated:TRUE];
            [self hideLabelsAndSwitches:TRUE];
            [locationManager stopUpdatingLocation];

        }
        else {
            [self.alarmSwitch setOn:TRUE];
            [alert dismissWithClickedButtonIndex:0 animated:TRUE];
            self.statusLabel.text = @"Wrong Password";
        }
    }
    
}

- (IBAction)alarmSwitch:(id)sender {
    NSLog(@"I am pressed");

    alert = [[UIAlertView alloc]
                              initWithTitle:@"Disable Alarm"
                              message:@"Enter your password before the timer ends"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Disable", nil];
    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [alert show];
    
}

- (IBAction)logoutButtonPressed:(id)sender {
    [PFUser logOut];
    NSLog(@"User has been logged out");
    [locationManager stopUpdatingLocation];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

#pragma mark - GPS Code

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"didUpdateToLocation: %@", [locations lastObject]);
    
    CLLocation *currentLocation = [locations lastObject];
    
    //    if (currentLocation.horizontalAccuracy < userData.currentAccuracy) {
    userData.currentAccuracy = currentLocation.horizontalAccuracy;
    
    NSLog(@"Resolving the Address\n");
    NSLog(@"ACCURACY %f %f", currentLocation.horizontalAccuracy, currentLocation.verticalAccuracy);
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                                      longitude:currentLocation.coordinate.longitude];
    
    PFUser *currUser = [PFUser currentUser];
    
    // Update Data table.
    PFObject *postObject = [PFObject objectWithClassName:@"Data"];
    [postObject setObject:currUser forKey:@"User"];
    [postObject setObject:currentPoint forKey:@"GeoLocation"];
    [postObject setObject:userData.currentStatus forKey:@"Status"];
    
    //TODO: Timestamp needs to go to the Server too! Figure out a way!
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error) // Failed to save, show an alert view with the error message
         {
             UIAlertView *alertView =
             [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"]
                                        message:nil
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil];
             [alertView show];
             return;
         }
         if (succeeded) // Successfully saved, post a notification to tell other view controllers
         {
             NSLog(@"Saved in Backend");
         };
         
     }];
    
    // Update User table.
    
    [currUser setObject:currentPoint forKey:@"recentLocation"];
    [currUser setObject:userData.currentStatus forKey:@"Status"];
    [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error) // Failed to save, show an alert view with the error message
         {
             UIAlertView *alertView =
             [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"]
                                        message:nil
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil];
             [alertView show];
             return;
         }
         if (succeeded) // Successfully saved, post a notification to tell other view controllers
         {
             NSLog(@"Saved in User Table");
         };
         
     }];
    
    NSLog(@"I reached Here");
    
//    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
//        if (error == nil && [placemarks count] > 0) {
//            placemark = [placemarks lastObject];
//            self.address.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
//                                 placemark.subThoroughfare, placemark.thoroughfare,
//                                 placemark.postalCode, placemark.locality,
//                                 placemark.administrativeArea,
//                                 placemark.country];
//        } else {
//            NSLog(@"%@", error.debugDescription);
//        }
//    } ];
    //    }
    //    else {
    //        NSLog(@"Not So Accurate!");
    //    }
}

#pragma mark - Timer Code

- (void)updateCounter:(NSTimer *)theTimer {
    
    if(secondsLeft > 0 ){
        secondsLeft -- ;
        NSLog(@" Inside %d", secondsLeft);
        self.timerLabel.text = [NSString stringWithFormat:@"%d", secondsLeft];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCounter:) userInfo:nil repeats:NO];
    }
    else {
        self.statusLabel.text = @"Alarm Activated";
        userData.currentStatus = @"ALARM";
        NSLog(@" Outside %d", secondsLeft);
        if (timer){
            [timer invalidate];
            timer = nil;
        }
        if (alert) {
            [alert dismissWithClickedButtonIndex:0 animated:TRUE];
        }
        self.timerLabel.text = [NSString stringWithFormat:@"%d", COUNTDOWN_START];
        [self hideLabelsAndSwitches:TRUE];
        
        // TODO: Push Notification Initiation.
    }
}

-(void) hideLabelsAndSwitches:(BOOL)flag {
    [self.alarmSwitch setOn:TRUE animated:TRUE];
    [self.alarmSwitch setHidden:flag];
    [self.alarmLabel setHidden:flag];
    [self.timerLabel setHidden:flag];
}

- (void)dealloc {
    [_timerLabel release];
    [_alarmLabel release];
    [_alarmSwitch release];
    [_statusLabel release];
    [_userLabel release];
    [super dealloc];
}
@end

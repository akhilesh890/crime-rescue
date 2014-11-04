//  MainViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/25/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import "RemoteConnector.h"

#define COUNTDOWN_START 9

@interface MainViewController ()

@end

@implementation MainViewController{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    UIAlertView *alert;
    NSTimer *timer;
    UserActivity *userData;
    int secondsLeft;
    PFUser *currentUser;
    NSDictionary *content;
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    NSLog(@"ViewDidLoad");
    [super viewDidLoad];
    [self hideLabelsAndSwitchesAndButtons:TRUE];
    currentUser = [PFUser currentUser];
    if (currentUser == false) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    NSLog(@"ViewDidLoad Done");
}

-(void)viewWillAppear:(BOOL)animated {
    currentUser = [PFUser currentUser];
    NSLog(@"ksjflskfjslkdfjlskf");
    NSLog(@"UID is %@",currentUser[@"uid"]);
    userData = [[UserActivity alloc] initWithStatus];
    [self hideLabelsAndSwitchesAndButtons:TRUE];
    self.statusLabel.text = @"Press Above";
    self.userLabel.text = [NSString stringWithFormat:@"Welcome, %@",[currentUser username]];
    NSLog(@"ViewWillAppear");
    NSLog(@"ViewWillAppear Done");
    userData.currentStatus = @"PASSIVE";
    
    //Setup Push Notification Settings
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"mode"] = @"Normal";
    [currentInstallation saveInBackground];
    
    // Code for GPS.
    
    geocoder = [[CLGeocoder alloc] init];
    secondsLeft = COUNTDOWN_START;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"%d", secondsLeft);
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [locationManager stopUpdatingLocation];
}

#pragma mark - Button Methods

- (IBAction)helpButtonTouchDown:(id)sender {
    //GPS Data sent.
    NSLog(@"Pressed");
    self.statusLabel.text = @"Keep Pressed Until Danger";
    [locationManager startUpdatingLocation];
    userData.currentStatus = @"ENABLED";
}

- (IBAction)helpButtonTouchUp:(id)sender {
    self.statusLabel.text = @"Cancel Alarm?";
    NSLog(@"Released");
    userData.currentStatus = @"DISABLED";
    [self sendRemoteData];
    userData.currentAccuracy = DBL_MAX;
    secondsLeft = COUNTDOWN_START;
    self.timerLabel.text = [NSString stringWithFormat:@"%d", COUNTDOWN_START];
    [self hideLabelsAndSwitchesAndButtons:FALSE];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:NO];   // Start the Timer
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self.alarmSwitch setOn:TRUE animated:TRUE];
    }
    if (buttonIndex == 1) {
        NSString *passwordEntered = [alert textFieldAtIndex:0].text;
        if ([passwordEntered isEqualToString:currentUser[@"passcode"]]) {
            self.statusLabel.text = @"Alarm Disabled";
            NSLog(@"Alarm Disabled");
            secondsLeft = 0;
            if (timer){
                [timer invalidate];
                timer = nil;
            }
            [alert dismissWithClickedButtonIndex:0 animated:TRUE];
            [self hideLabelsAndSwitchesAndButtons:TRUE];
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
    
    currentLocation = [locations lastObject];
    
    //    if (currentLocation.horizontalAccuracy < userData.currentAccuracy) {
    userData.currentAccuracy = currentLocation.horizontalAccuracy;
    
    NSLog(@"Resolving the Address\n");
    NSLog(@"ACCURACY %f %f", currentLocation.horizontalAccuracy, currentLocation.verticalAccuracy);
    
    [self sendRemoteData];
    
    NSLog(@"I reached Here");
    
}


-(void) sendRemoteData {
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                                      longitude:currentLocation.coordinate.longitude];
    
    PFUser *currUser = [PFUser currentUser];
    
    // Update Data table.
    PFObject *postObject = [PFObject objectWithClassName:@"Data"];
    [postObject setObject:currUser forKey:@"User"];
    [postObject setObject:currentPoint forKey:@"GeoLocation"];
    [postObject setObject:userData.currentStatus forKey:@"Status"];
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    //NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //NSLog(dateString);
    [postObject setObject:currDate forKey:@"TimeStamp"];
    
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
         if (succeeded) // Saved in Parse, now trying in UIUC backend.
         {
             NSString *latitudeString =  [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.latitude];
             NSString *longitudeString = [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.longitude];
             NSNumber *latitude = @([latitudeString doubleValue]);
             NSNumber *longitude = @([longitudeString doubleValue]);
             //NSNumber *timestamp = [[NSNumber alloc] initWithDouble:10000];
             
             NSLog(@"Entering UIUC Backend");
             NSError *error;
             NSURL *url = [NSURL URLWithString:@"http://dharmaseth.web.engr.illinois.edu/CrimeRescue/insertData.php"];
             
             content = [[NSDictionary alloc] initWithObjectsAndKeys:
                        currentUser[@"uid"], @"uid",
                        latitude, @"latitude",
                        longitude, @"longitude",
                        userData.currentStatus, @"status",
                        nil];
             
             NSData *postData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
             NSData *responseData = [[NSData alloc] initWithData:[RemoteConnector sendAndReceiveJSONRequest:postData :url]];
             NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
             NSLog(@"the final Data is:%@",responseString);
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
        [self hideLabelsAndSwitchesAndButtons:TRUE];
        [self sendRemoteData];
        
        //[rC sendRemoteData:currentLocation :userData];
        
//        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
//        [geocoder reverseGeocodeLocation:currentLocation
//                       completionHandler:^(NSArray *placemarks, NSError *error) {
//                           NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
//                           
//                           if (error){
//                               NSLog(@"Geocode failed with error: %@", error);
//                               return;
//                               
//                           }
//                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
//                           
//                           NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
//                           NSLog(@"placemark.country %@",placemark.country);
//                           NSLog(@"placemark.postalCode %@",placemark.postalCode);
//                           NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
//                           NSLog(@"placemark.locality %@",placemark.locality);
//                           NSLog(@"placemark.subLocality %@",placemark.subLocality);
//                           NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
//                           
//                       }];
        
        NSString *alertString = [NSString stringWithFormat: @"Help %@! Lat: %@ Long: %@", [currentUser username], [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.latitude], [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.longitude]];
        
        // TODO: Push Notification Initiation.
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"mode" equalTo:@"Patrol"];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:pushQuery
                                       withMessage:alertString];
    }
}

-(void) hideLabelsAndSwitchesAndButtons:(BOOL)flag {
    [self.alarmSwitch setOn:TRUE animated:TRUE];
    [self.alarmSwitch setHidden:flag];
    [self.alarmLabel setHidden:flag];
    [self.alarmStatusLabel setHidden:flag];
    [self.timerLabel setHidden:flag];
    self.helpButton.enabled = flag;
    if (flag) {
        self.helpButton.alpha = 1.0; // If Button is enabled, its made visible
    }
    else {
        self.helpButton.alpha = 0.1; // If Button is disabled, its made invisible
    }
}
@end
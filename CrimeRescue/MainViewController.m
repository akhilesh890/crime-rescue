//  MainViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/25/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

@interface MainViewController ()

@end

@implementation MainViewController{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    UserActivity *userData;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ViewDidLoad");
    PFUser *currentUser = [PFUser currentUser];
   // NSLog(currentUser[@"firstname"]);
    if (currentUser == false) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    NSLog(@"ViewDidLoad Done");
}

-(void)viewDidAppear:(BOOL)animated {
 //   PFUser *currentUser = [PFUser currentUser];
    userData = [[UserActivity alloc] initWithStatus];
    
    NSLog(@"%f", userData.currentAccuracy);
    NSLog(@"%@", userData.currentStatus);
    
    NSLog(@"ViewDidAppear");
   // NSLog(currentUser[@"firstname"]);
    NSLog(@"ViewDidAppear Done");
    
}

#pragma mark - Button Methods

- (IBAction)helpButtonTouchDown:(id)sender {
    //GPS Data sent.
    NSLog(@"Pressed");
   // locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    userData.currentStatus = @"ACTIVE";
    
    //TODO: Send GPS data to backend, keep track of best estimate.
    //TODO: States Change etc.
}

- (IBAction)helpButtonTouchUp:(id)sender {
    //TODO: Wait for the timeout period and set alarm, by initiating push notifications.
    [locationManager stopUpdatingLocation];
    NSLog(@"Released");
    self.address = nil;
    self.latitude = nil;
    self.longitude = nil;
    userData.currentStatus = @"PASSIVE";
    userData.currentAccuracy = DBL_MAX;
    
}

- (IBAction)alarmSwitch:(id)sender {
    NSLog(@"I am pressed");
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Disable Alarm" message:@"Enter your Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert addButtonWithTitle:@"Disable"];
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
    
    if (currentLocation.horizontalAccuracy < userData.currentAccuracy) {
        userData.currentAccuracy = currentLocation.horizontalAccuracy;
        if (currentLocation != nil) {
            self.longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            self.latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        }
        
        
        NSLog(@"Resolving the Address\n");
        NSLog(@"ACCURACY %f %f", currentLocation.horizontalAccuracy, currentLocation.verticalAccuracy);
        
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                                          longitude:currentLocation.coordinate.longitude];
        
        PFUser *currUser = [PFUser currentUser];
        // Create a PFObject using the Post class and set the values we extracted above
        PFObject *postObject = [PFObject objectWithClassName:@"Data"];
        [postObject setObject:currUser forKey:@"User"];
        [postObject setObject:currentPoint forKey:@"GeoLocation"];
        
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
        
        [currUser setObject:currentPoint forKey:@"recentLocation"];
        
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
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (error == nil && [placemarks count] > 0) {
                placemark = [placemarks lastObject];
                self.address.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                     placemark.subThoroughfare, placemark.thoroughfare,
                                     placemark.postalCode, placemark.locality,
                                     placemark.administrativeArea,
                                     placemark.country];
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
    }
    else {
        NSLog(@"Not So Accurate!");
    }
}


- (void)dealloc {
    [_timerLabel release];
    [_alarmLabel release];
    [super dealloc];
}
@end

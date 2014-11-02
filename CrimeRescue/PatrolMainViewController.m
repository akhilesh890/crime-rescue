//
//  PatrolMainViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 5/10/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "PatrolMainViewController.h"
#import <Parse/Parse.h>

@interface PatrolMainViewController ()

@end

@implementation PatrolMainViewController{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    //    UIAlertView *alert;
    NSTimer *timer;
    int secondsLeft;
    PFUser *currentUser;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Patrol ViewDidLoad");
    [self performSegueWithIdentifier:@"showPatrolLogin" sender:self];
}

-(void)viewWillAppear:(BOOL)animated{
   PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"mode"]=@"Patrol";
    [currentInstallation saveInBackground];
    NSLog(@"Patrol ViewDidLoad Done");
    currentUser = [PFUser currentUser];
    self.userLabel.text = [NSString stringWithFormat:@"Welcome, %@",[currentUser username]];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"Status" equalTo:@"ALARM"] ;
   //[query selectKeys:@[@"email"]];
   //    PFObject *first = [query getFirstObject];
  //    NSString *f = first[@"email"];
//    NSLog(f);
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *entries, NSError *error) {
        NSString *result = @"EMAIL: \n";
        // Comments now contains the last ten comments, and the "post" field
        // has been populated. For example:
        for (PFObject *entry in entries) {
            // This does not require a network access.
            PFObject *post = entry[@"email"];
            NSString *p = post;
            result = [result stringByAppendingString:p];
            result = [result stringByAppendingString:@"\n"];
            NSLog(@"retrieved related post: %@", p);
        }
        self.printLabel.text = result;
    }];
    
    NSLog(@"View Appeared");
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"%d", secondsLeft);
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [locationManager stopUpdatingLocation];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [PFUser logOut];
    NSLog(@"User has been logged out");
    [locationManager stopUpdatingLocation];
    [self performSegueWithIdentifier:@"showPatrolLogin" sender:self];
}

- (IBAction)toggleLocationSwitch:(id)sender {
    NSLog(@"I  pressed!");
    if ([self.locationSwitch isOn]) {
    //    [self.locationSwitch setOn:FALSE animated:TRUE];
        [locationManager startUpdatingLocation];
        NSLog(@"ON");
    }
    else {
      //  [self.locationSwitch setOn:TRUE animated:TRUE];
        [locationManager stopUpdatingLocation];
        NSLog(@"OFF");
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
    }
}

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
    NSLog(@"Resolving the Address\n");
    NSLog(@"ACCURACY %f %f", currentLocation.horizontalAccuracy, currentLocation.verticalAccuracy);
    self.latitudeLabel.text = [NSString stringWithFormat:@"%lf",currentLocation.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%lf",currentLocation.coordinate.longitude];
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
    [postObject setObject:@"ACTIVE" forKey:@"Status"];
    [postObject setObject:@"PATROL" forKey:@"Mode"];
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    
    //NSLog(dateString);
    [postObject setObject:currDate forKey:@"TimeStamp"];
    //TODO: PHP Integration.
    
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
    [currUser setObject:@"ACTIVE" forKey:@"Status"];
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

@end

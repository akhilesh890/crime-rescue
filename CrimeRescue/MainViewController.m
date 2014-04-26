//
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

@implementation MainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Come Here");
    [self performSegueWithIdentifier:@"showLogin" sender:self];
    NSLog(@"Done");
}

- (IBAction)logoutButtonPressed:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (IBAction)helpButtonPressed:(id)sender {
    //GPS Data sent.
    NSLog(@"Pressed");
}
@end

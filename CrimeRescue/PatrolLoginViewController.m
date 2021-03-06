//
//  PatrolLoginViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 5/10/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "PatrolLoginViewController.h"
#import <Parse/Parse.h>

@interface PatrolLoginViewController ()

@end

@implementation PatrolLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    NSLog(@"Login Reached");
}

- (IBAction)signInButtonPressed:(id)sender {
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username and password!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    else {
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:username];
        NSArray *candidate = [query findObjects];
        NSString *mode = nil;
        BOOL isPatrolUser = YES;
        
        if ([candidate count] > 0) {
            PFUser *referenceUser = [candidate objectAtIndex:0];
            mode = referenceUser[@"Mode"];
            if ([mode  isEqual: @"NORMAL"]) {
                isPatrolUser = NO;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:@"You are already registered in Normal Mode"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
        
        if (isPatrolUser == YES)
        {
            [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                        message:[error.userInfo objectForKey:@"error"]
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

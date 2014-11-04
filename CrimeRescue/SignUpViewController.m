//
//  SignUpViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/25/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "RemoteConnector.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Reached SignUp");
    self.navigationItem.backBarButtonItem.title = @"Sign In";
    
}

- (IBAction)signupButtonPressed:(id)sender {
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *firstname = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phone = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *status = @"ACTIVE";
    NSLog(password);
    
    if ([username length] == 0 || [firstname length] == 0 ||
        [password length] == 0 || [email length] == 0 || [phone length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you didnt leave out any field!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    else {
        
        //Update Parse Backend
        
        bool success = YES;
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        newUser[@"phone"] = phone;
        newUser[@"firstname"] = firstname;
        newUser[@"passcode"] = password;
        newUser[@"Mode"] = @"NORMAL";
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                NSLog(@"Met this Error Phase");
            }
            
            // If Parse worked fine, it proceeds to private cloud. (UIUC Cloud)
 
            else {
               NSString *currObjId = newUser.objectId;
                NSLog(@"Object id %@", currObjId);

                NSLog(@"Entering UIUC Backend");
                NSError *error;
                NSURL *url = [NSURL URLWithString:@"http://dharmaseth.web.engr.illinois.edu/CrimeRescue/insertUser.php"];
                NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     username, @"uname",
                                     password, @"password",
                                     firstname, @"firstname",
                                     firstname, @"lastname",
                                     email, @"email",
                                     phone, @"cellphone",
                                     status, @"status",
                                     nil];
                
                NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:NSJSONWritingPrettyPrinted error:&error];
                
                NSData *responseData = [[NSData alloc] initWithData:[RemoteConnector sendAndReceiveJSONRequest:postData :url]];
                NSLog(@"Before Error: %@ %@", error, [error userInfo]);
                NSDictionary *responseDictionary=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:&error];
                //NSArray *responseDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:responseData];
                //NSDictionary *responseDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:responseData];
                
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSLog(@"the final output is: %@",responseString);
                NSLog(@"After Error: %@ %@", error, [error userInfo]);
                NSLog(@"Array: %@", responseDictionary);
                
                if (responseDictionary[@"uid"] != nil) {
                    NSString *uidString = [responseDictionary objectForKey:@"uid"];
                    NSLog(@"%@", uidString);
                    
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber * uidNum = [f numberFromString:uidString];
                    NSLog(@"%@", uidNum);
                    PFQuery *query = [PFUser query];
                    PFUser *currentUser = [query getObjectWithId:currObjId];
                    NSLog(currentUser[@"username"]);
                    [currentUser setObject:uidNum forKey:@"uid"];
                    [currentUser save];
                    NSLog(@"Saved");
                }
                
                NSLog(@"Reached here!");
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}

@end

//
//  TimeControllerViewController.h
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/30/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeControllerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *myCounterLabel;

-(void)updateCounter:(NSTimer *)theTimer;

@end

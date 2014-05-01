//
//  TimeControllerViewController.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/30/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "TimeControllerViewController.h"

@implementation TimeControllerViewController{
    int secondsLeft;
    NSTimer *timer;
}

@synthesize myCounterLabel;


- (void)viewDidLoad {
    [super viewDidLoad];
    secondsLeft = 5;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:NO];
    
}

-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"%d", secondsLeft);
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(secondsLeft > 0 ){
        secondsLeft -- ;
        NSLog(@" Inside %d", secondsLeft);
        
        myCounterLabel.text = [NSString stringWithFormat:@"%02d", secondsLeft];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCounter:) userInfo:nil repeats:NO];
    }
    else {
        NSLog(@" Outside %d", secondsLeft);
        //secondsLeft = 15;
        [timer invalidate];
        timer = nil;
        [self performSegueWithIdentifier:@"showMain" sender: self];
        
    }
}

@end

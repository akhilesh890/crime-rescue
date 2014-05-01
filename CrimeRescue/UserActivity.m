//
//  UserActivity.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/30/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "UserActivity.h"

@implementation UserActivity

- (id) initWithStatus {
    
    self = [super init];
    if (self) {
        self.currentStatus = @"PASSIVE";
        self.currentAccuracy = DBL_MAX;
    }
    return self;
}

-(void) clear {
    self.currentAccuracy = 0;
    self.currentStatus = @"PASSIVE";
}


@end

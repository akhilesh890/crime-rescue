//
//  UserActivity.h
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 4/30/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef enum UserStatusTypes
{
    PASSIVE,
    ENABLED,
    DISABLED,
    ALARM
} Status;


@interface UserActivity : NSObject

@property (nonatomic, assign) CLLocationAccuracy currentAccuracy;
@property (nonatomic, strong) NSString* currentStatus;

- (id) initWithStatus;
-(void) clear;

@end

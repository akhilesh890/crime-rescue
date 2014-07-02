//
//  RemoteConnector.m
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 6/15/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import "RemoteConnector.h"

@implementation RemoteConnector : NSObject

+ (NSData *)sendAndReceiveJSONRequest:(NSData *)sendData :(NSURL *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData* responseData = [NSMutableData data];
    NSError *error;
    NSLog(error);
    NSLog(@"Above Error");
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [sendData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:sendData];
    NSURLResponse* response = nil;
    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    return responseData;
}

@end

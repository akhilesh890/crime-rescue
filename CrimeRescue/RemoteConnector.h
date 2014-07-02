//
//  RemoteConnector.h
//  CrimeRescue
//
//  Created by Aswin Akhilesh on 6/15/14.
//  Copyright (c) 2014 Aswin Akhilesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

/*! Handles all client-server interactions.
 */
@interface RemoteConnector : NSObject

/*! Converts NSData to JSON, and sends a http GET request to the url provided
 \param sendData NSData that is sent to server
 \param url The Server location
 \returns response from the server in NSData form
*/

+ (NSData *)sendAndReceiveJSONRequest:(NSData *)sendData :(NSURL *)url;
@end

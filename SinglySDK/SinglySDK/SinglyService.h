//
//  SinglyService.h
//  SinglySDK
//
//  Copyright (c) 2012 Singly, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SinglyService : NSObject

/*!
 *
 * The service identifier (e.g. "facebook", "twitter", etc).
 *
**/
@property (nonatomic, strong) NSString *serviceIdentifier;

/*!
 *
 * The client id for the service. This may be fetched (asynchronously) by
 * calling fetchClientID.
 *
**/
@property (nonatomic, strong) NSString *clientID;

/*!
 *
 * Whether or not the service is currently authorized.
 *
**/
@property (nonatomic, assign) BOOL isAuthorized;

/*!
 *
 * Convenience method that will return an instance of SinglyService initialized
 * by the service identifier.
 *
 * @param serviceIdentifier The service identifier (e.g. "facebook", "twitter", etc).
 *
**/
+ (id)serviceWithIdentifier:(NSString *)serviceIdentifier;

/*!
 *
 * Initializes with serviceIdentifier;
 *
 * @param serviceIdentifier The service identifier (e.g. "facebook", "twitter", etc).
 *
**/
- (id)initWithIdentifier:(NSString *)serviceIdentifier;

/*!
 *
 * Fetches the client id from Singly.
 *
**/
- (void)fetchClientID;

@end

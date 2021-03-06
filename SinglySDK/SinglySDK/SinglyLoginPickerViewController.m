//
//  SinglyLoginPickerViewController.m
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

#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>

#import "SinglyConstants.h"
#import "SinglyLoginPickerViewController.h"
#import "SinglyLoginPickerServiceCell.h"
#import "SinglyFacebookService.h"
#import "SinglyActivityIndicatorView.h"

@interface SinglyLoginPickerViewController ()

@property (nonatomic, strong) NSString *selectedService;

- (void)disconnectFromService:(NSString *)service;

@end

@implementation SinglyLoginPickerViewController

-(id)initWithSession:(SinglySession *)session
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //
    // Observe for changes to the session profiles and update the view when
    // changes occur (such as when a session is connected or disconnected).
    //
    [[NSNotificationCenter defaultCenter] addObserverForName:kSinglyNotificationSessionProfilesUpdated
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

    // Load Services Dictionary
    // TODO We may want to move this to SinglySession
    if (!self.servicesDictionary)
    {

        // Display Activity Indicator
        [SinglyActivityIndicatorView showIndicator];

        // Load Services Dictionary
        NSURL *servicesURL = [NSURL URLWithString:@"https://api.singly.com/services"];
        NSURLRequest *servicesRequest = [NSURLRequest requestWithURL:servicesURL];
        [NSURLConnection sendAsynchronousRequest:servicesRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *requestError) {
            _servicesDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            if (!self.services)
                self.services = [self.servicesDictionary allKeys];

            // Dismiss the Activity Indicator
            [SinglyActivityIndicatorView dismissIndicator];

            // Reload the Table View
            [self.tableView reloadData];
        }];

        // Customize Table View Appearance
        self.tableView.rowHeight = 54;

    }
    else if (self.servicesDictionary && !self.services)
    {
        self.services = [self.servicesDictionary allKeys];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [SinglyActivityIndicatorView dismissIndicator];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    //
    // Stop observing for updates to the session profiles.
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSinglyNotificationSessionProfilesUpdated
                                                  object:nil];
}

#pragma mark - SinglySession

- (SinglySession *)session
{
    if (!_session)
        _session = [SinglySession sharedSession];
    return _session;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"com.singly.SinglyLoginPickerServiceCell";
    SinglyLoginPickerServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[SinglyLoginPickerServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSString *service = [self.services objectAtIndex:indexPath.row];
    NSDictionary *serviceInfoDictionary = [self.servicesDictionary objectForKey:service];
    cell.serviceInfoDictionary = serviceInfoDictionary;
    
    if ([self.session.profiles objectForKey:service])
        cell.authenticated = YES;
    else
        cell.authenticated = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *service = [self.services objectAtIndex:indexPath.row];
    self.selectedService = service;

    // Do nothing if we are already authenticated against the selected service
    if ([self.session.profiles objectForKey:service])
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Disconnect from %@?", self.servicesDictionary[service][@"name"]]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Disconnect", nil];
        [alertView show];
        return;
    }
    
    // Override the standard behavior for Facebook
    if ([service isEqualToString:kSinglyServiceFacebook])
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self authenticateWithFacebook];
        return;
    }
    
    // Display the standard login view controller
    [self authenticateWithService:service];
}

#pragma mark - Alert View Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 0: // Disconnect
            switch (buttonIndex)
            {
                case 0: // Cancel
                    break;
                case 1: // Disconnect
                    [self disconnectFromService:self.selectedService];
                    break;
            }
            break;

        default:
            break;
    }
}

#pragma mark - Singly Login View Controller delegate

- (void)singlyLoginViewController:(SinglyLoginViewController *)controller didLoginForService:(NSString *)service;
{
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)singlyLoginViewController:(SinglyLoginViewController *)controller errorLoggingInToService:(NSString *)service withError:(NSError *)error;
{
    [self dismissViewControllerAnimated:NO completion:nil];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Service-Specific Authentication

- (void)authenticateWithService:(NSString *)service
{
    SinglyLoginViewController *loginViewController = [[SinglyLoginViewController alloc] initWithSession:self.session forService:service];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:YES completion:NULL];
}

- (void)authenticateWithFacebook
{

    SinglyFacebookService *facebookService = [SinglyService serviceWithIdentifier:@"facebook"];
    [facebookService requestAuthorizationWithViewController:self];

}

// TODO Move this to SinglyService
- (void)disconnectFromService:(NSString *)service
{

    // TODO Profile IDs return as an array. Are multiple profiles supported?

    NSURL *profilesURL = [NSURL URLWithString:@"https://api.singly.com/profiles"];
    NSString *postString = [NSString stringWithFormat:@"delete=%@&access_token=%@",
                            [NSString stringWithFormat:@"%@@%@", [[[SinglySession sharedSession] profiles] objectForKey:service][0], service],
                            [SinglySession sharedSession].accessToken];

    NSMutableURLRequest *disconnectRequest = [NSMutableURLRequest requestWithURL:profilesURL];
    [disconnectRequest setHTTPMethod:@"POST"];
    [disconnectRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection sendAsynchronousRequest:disconnectRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {

        // TODO Handle Errors...

        [[SinglySession sharedSession] updateProfilesWithCompletion:^{
            [self.tableView reloadData];
        }];

    }];

}

@end

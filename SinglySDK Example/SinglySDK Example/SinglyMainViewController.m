//
//  SinglyMainViewController.m
//  SinglySDK Example
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

#import "SinglyMainViewController.h"

@interface SinglyMainViewController ()

@end

@implementation SinglyMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    // Disable examples unless authenticated...
    if (![SinglySession sharedSession].accessToken)
    {
        self.friendPickerCell.userInteractionEnabled = NO;
        self.friendPickerCell.textLabel.alpha = 0.25;
        self.friendPickerCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        self.friendPickerCell.userInteractionEnabled = YES;
        self.friendPickerCell.textLabel.alpha = 1.0;
        self.friendPickerCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
//    if (section == 0 && ![SinglySession sharedSession].accessToken)
//    {
//        return @"You must authenticate with a service to access the following examples";
//    }
    return nil;
}

@end

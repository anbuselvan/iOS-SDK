//
//  SinglyLoginPickerServiceCell.m
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

#import <QuartzCore/QuartzCore.h>
#import "SinglyLoginPickerServiceCell.h"

@interface SinglyLoginPickerServiceCell ()

@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) UIButton *button;

@end

@implementation SinglyLoginPickerServiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.imageView.image = [UIImage imageNamed:@"SinglySDK.bundle/Service Placeholder"];
        self.imageView.layer.cornerRadius = 3.0;
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;

        self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.button.frame = CGRectMake(self.bounds.size.width - 8 - 80, 10, 80, 28);
        self.button.titleLabel.shadowColor = [UIColor darkGrayColor];
        self.button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.button.userInteractionEnabled = NO;

        self.textLabel.font = [UIFont systemFontOfSize:16];

        self.accessoryView = self.button;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.imageView.frame = CGRectMake((self.frame.size.height - 32) / 2, (self.frame.size.height - 32) / 2, 32, 32);
    self.textLabel.frame = CGRectMake(32 + (self.frame.size.height - 32), 0, self.textLabel.frame.size.width - 48, self.textLabel.frame.size.height);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageConnection cancel];
    self.imageView.image = [UIImage imageNamed:@"SinglySDK.bundle/Service Placeholder"];
}

- (void)setServiceInfoDictionary:(NSDictionary *)serviceInfoDictionary
{
    _serviceInfoDictionary = serviceInfoDictionary;
    
    // Set Text Label
    self.textLabel.text = serviceInfoDictionary[@"name"];

    // Load Image
    NSURL *imageURL = [NSURL URLWithString:serviceInfoDictionary[@"icons"][2][@"source"]];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
    self.receivedData = [NSMutableData data];
    self.imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self startImmediately:NO];
    [self.imageConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.imageConnection start];
}

- (void)setAuthenticated:(BOOL)authenticated
{
    _authenticated = authenticated;

    if (authenticated)
    {
        [self disableColorButton:self.button];
        [self.button setTitle:@"Logged In" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.enabled = NO;
    }
    else
    {
        [self enableColorButton:self.button];
        [self.button setTitle:@"Log In" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.enabled = YES;
    }

    [self.button bringSubviewToFront:self.button.titleLabel];
}

#pragma mark - URL Connection Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.imageView.image = [UIImage imageWithData:self.receivedData];
    self.imageConnection = nil;
    self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    self.imageConnection = nil;
    self.receivedData = nil;
}

- (void)enableColorButton:(UIButton *)button;
{
    // Add Border
    CALayer *layer = button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, -1);
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithRed:0.537 green:0.604 blue:0.690 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.318 green:0.443 blue:0.592 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.227 green:0.361 blue:0.529 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.235 green:0.369 blue:0.533 alpha:1.0].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer addSublayer:shineLayer];
}

- (void)disableColorButton:(UIButton *)button
{
    // Add Border
    CALayer *layer = button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.2f].CGColor;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, -1);
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1.0].CGColor,
                         (id)[UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1.0].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer addSublayer:shineLayer];
}

@end

//
//  DistanceViewController.m
//  iXplorCanada
//
//  Created by Adam on 3/14/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "DistanceViewController.h"
#import "GlobalVariable.h"

@interface DistanceViewController ()

@end

@implementation DistanceViewController
@synthesize webView, btnBack ;

-(IBAction)onReturn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%g,%g&daddr=%g,%g", [GlobalVariable sharedInstance].lat1, [GlobalVariable sharedInstance].lng1, [GlobalVariable sharedInstance].lat2, [GlobalVariable sharedInstance].lng2];
    NSURL *url = [NSURL URLWithString:stringURL];
    //[[UIApplication sharedApplication] openURL:url];
    NSURLRequest*request=[NSURLRequest requestWithURL:url];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //5
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) [webView loadRequest:request];
         else if (error != nil) NSLog(@"Error: %@", error);
     }];
    
    [btnBack setContentEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)] ;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

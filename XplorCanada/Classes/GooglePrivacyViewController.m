//
//  GooglePrivacyViewController.m
//  iXplorCanada
//
//  Created by Kang on 6/13/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "GooglePrivacyViewController.h"
#import "GlobalVariable.h"

@interface GooglePrivacyViewController ()

@end

@implementation GooglePrivacyViewController
@synthesize webView, label_Title ;

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
	
    NSString *stringURL = @"" ;
    
    if ([GlobalVariable sharedInstance].url_google_privacy_kind == 1 )
    {
        [label_Title setText:@"Google Terms and Use"] ;
        stringURL = @"https://www.google.com/intl/en/policies/terms" ;
    }
    else
    {
        [label_Title setText:@"Google Privacy Policy"] ;
        stringURL = @"https://www.google.com/policies/privacy" ;
    }
    
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest*request=[NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ([data length] > 0 && error == nil) [webView loadRequest:request];
            else if (error != nil) NSLog(@"Error: %@", error);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  BusinessViewController.m
//  xplor
//
//  Created by Adam on 3/3/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "BusinessViewController.h"
#import "ASIFormDataRequest.h"
#import "XMLParser.h"
#import "NSData+Base64.h"
#import "GlobalVariable.h"
#import "ASIHTTPRequest.h"

@interface BusinessViewController ()

@end

@implementation BusinessViewController
@synthesize txtEmail, txtName, txtPhoneNumber, txtBizName, swh_featured ;

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
    
    [headerView setBackgroundColor:[UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(250/255.0) alpha:1]];
    
    return headerView;
}

-(IBAction)onSubmit:(id)sender
{
    if ( [txtName.text length] < 1 )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please type your name."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView  show];
    }
    else if ( [txtEmail.text length] < 1 )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please type your Email address."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView  show];
    }
    else if ( [txtPhoneNumber.text length] < 1 )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please type your Phone number."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView  show];
    }
    else if ( [txtBizName.text length] < 1 )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please type your Business name."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView  show];
    }
    else if ( [[GlobalVariable sharedInstance].position_kind length] < 1 )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please select business category."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView  show];
    }
    else
    {
        NSString *apiString = [[GlobalVariable sharedInstance].webserver_address stringByAppendingString:@"add_business.php"];
        NSURL *apiURL = [NSURL URLWithString:apiString];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:apiURL];
        request.requestMethod = @"POST";
        
        NSLog(@"%@",[GlobalVariable sharedInstance].position_kind) ;
        [request addPostValue:txtName.text forKey:@"user_name"];
        [request addPostValue:txtEmail.text forKey:@"email"];
        [request addPostValue:txtPhoneNumber.text forKey:@"phone_number"];
        [request addPostValue:txtBizName.text forKey:@"business_name"];
        [request addPostValue:[GlobalVariable sharedInstance].position_kind forKey:@"category_id"];
        
        if (swh_featured.on)
            [request addPostValue:@"1" forKey:@"featured"];
        else
            [request addPostValue:@"0" forKey:@"featured"];
        
        [request addPostValue:lattitudeStr forKey:@"lat"];
        [request addPostValue:longitudeStr forKey:@"lng"];
        
        [GlobalVariable sharedInstance].businessName = txtName.text ;
        [GlobalVariable sharedInstance].businessEmail = txtEmail.text ;
        [GlobalVariable sharedInstance].businessPhone = txtPhoneNumber.text ;
        
        [request setDelegate:self];
        [request startAsynchronous];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [HUD show:YES] ;
    }
}

- (void)requestFinished:(id)sender
{
    ASIFormDataRequest *request = (ASIFormDataRequest *)sender;
    NSString * responseString = [request responseString];
    
    [HUD show:NO] ;
    [HUD removeFromSuperview];
    
    int statusCode = [request responseStatusCode];
    if (statusCode == 200) {
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray  *dataArr =  [self parseDataWithDict:responseData];
        if ([dataArr count] > 0) {
            
            NSString  *responseMessage = [(NSDictionary *)[dataArr objectAtIndex:0] valueForKey:@"message"];
            if([responseMessage isEqualToString:@"1"])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information"
                                                                    message:@"Your request has submitted successfully."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                NSLog(@"%@",responseMessage) ;
                
                [alertView  show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information"
                                                                    message:@"Failed"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                NSLog(@"%@",responseMessage) ;
                [alertView  show];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Internet Connection Error."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView  show];
        }
    }
    
    [txtName setText:@""] ;
    [txtEmail setText:@""] ;
    [txtPhoneNumber setText:@""] ;
    [txtBizName setText:@""] ;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)txtDone:(id)sender
{
    [sender becomeFirstResponder];
    [sender resignFirstResponder];
    
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil]; 
}

- (void)dismissMyView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissMyView)] ;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    [_container setFrame:CGRectMake(0, 74, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 74)] ;
    [_container setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)] ;   
    
    [GlobalVariable sharedInstance].category_selected = @"" ;
    [GlobalVariable sharedInstance].position_kind = @"" ;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[GlobalVariable sharedInstance].category_selected length] > 1)
    {
        NSString* temp = [_btnBizCategory.titleLabel text] ;
        
        temp = [temp stringByAppendingString:@" - "] ;
        [_btnBizCategory setTitle:[temp stringByAppendingString:[GlobalVariable sharedInstance].category_selected] forState:UIControlStateNormal];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    lattitudeStr = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    longitudeStr = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestFailed:(id)sender
{
    [HUD show:NO] ;
    [HUD removeFromSuperview] ;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Access Denied for Server."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView  show];
    
    ASIFormDataRequest *request = (ASIFormDataRequest *)sender;
    
    [txtName setText:@""] ;
    [txtEmail setText:@""] ;
    [txtPhoneNumber setText:@""] ;
    
    NSLog(@"%@", [request.error localizedDescription]);
}

- (NSArray *)parseDataWithDict:(NSData *)_data
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_data] ;
    NSMutableDictionary *fectchDataDic = [NSMutableDictionary dictionaryWithCapacity:1] ;
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser:@"pagecontent"] ;
    [xmlParser setDelegate:parser] ;
    [xmlParser parse] ;
    
    [fectchDataDic setObject:parser.parsedXML forKey:@"root"] ;
    NSArray *dataArr=[fectchDataDic objectForKey:@"root"] ;
    
    return dataArr ;
}

-(IBAction)onReturn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES] ;
}

@end

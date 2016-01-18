//
//  SettingViewController.m
//  xplor
//
//  Created by Adam on 3/3/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "SettingViewController.h"
#import "GlobalVariable.h"

@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize btnBack ;

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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    tableData1 = [NSArray arrayWithObjects:@"English", @"Canadian", nil];
    
    tableData2 = [NSArray arrayWithObjects:@"App Version                    1.0", @"Rate on AppStore", @"Send Feedback", @"Google Terms and Use", @"Google Privacy Policy", nil];
    [btnBack setContentEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)] ;
}

- (void)dismissMyView {
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissMyView)] ;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IDIOM == IPAD )
        return 60 ;
    else
        return 50 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //if ( section == 0 )
    //    return [tableData1 count];
    //else
    return [tableData2 count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    //if ( section == 0 )
    //    return @"Choose Language" ;
    //else
    return @"iXplore" ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
   // if ( indexPath.section == 0 )
   // {
   //     cell.textLabel.text = [tableData1 objectAtIndex:indexPath.row];
   // }
   // else
   // {
        cell.textLabel.text = [tableData2 objectAtIndex:indexPath.row];
   // }
    
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if ( indexPath.row == 1 )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        @"http://itunes.apple.com/CN/app/id844584602?mt=8"]];
    }
    else if ( indexPath.row == 2 )
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@"Feedback Of iXplore"];
            NSArray *toRecipients = [NSArray arrayWithObjects:@"feedback@canadaworldapps.com", nil];
            [mailer setToRecipients:toRecipients];
            NSString *emailBody = @"";
            [mailer setMessageBody:emailBody isHTML:NO];
             [self presentViewController:mailer animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alert show];
        }
    }
    else if ( indexPath.row == 3 )
    {
        [GlobalVariable sharedInstance].url_google_privacy_kind = 1 ;
        [self performSegueWithIdentifier:@"toPrivacy" sender:self] ;
    }
    else if ( indexPath.row == 4 )
    {
        [GlobalVariable sharedInstance].url_google_privacy_kind = 2 ;
        [self performSegueWithIdentifier:@"toPrivacy" sender:self] ;
        
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
    
    [headerView setBackgroundColor:[UIColor colorWithRed:(7/255.0) green:(48/255.0) blue:(110/255.0) alpha:1]];
    
    return headerView;
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onReturn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES] ;
    
}

@end

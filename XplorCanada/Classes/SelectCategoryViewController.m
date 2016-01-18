//
//  SelectCategoryViewController.m
//  iXplorCanada
//
//  Created by Kang on 6/13/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "SelectCategoryViewController.h"

@interface SelectCategoryViewController ()

@end

@implementation SelectCategoryViewController
@synthesize bannerIsVisible ;

-(IBAction)onReturn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        if ( banner.frame.origin.y == [UIScreen mainScreen].bounds.size.height )
        {
            if ( IDIOM == IPAD )
                banner.frame = CGRectOffset(banner.frame, 0, -65);
            else
                banner.frame = CGRectOffset(banner.frame, 0, -50);
        }
        
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = YES;
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // ;
        // ;
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // resume everything you've stopped
    // ;
    // ;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        //banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    storyBoard = nil ;
    if ( IDIOM == IPAD )
        storyBoard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] ;
    else
        storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] ;
    
    if ( adView != nil )
    {
        [adView removeFromSuperview] ;
    }
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero] ;
    adView.delegate = self ;
    
    [self.view addSubview:adView] ;
    self.bannerIsVisible = NO ;
    
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifier320x50];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
    adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50,ADBannerContentSizeIdentifier480x32,nil];
    
    CGRect adFrame = adView.frame;
    adFrame.origin.y = [UIScreen mainScreen].bounds.size.height ;
    adView.frame = adFrame;
    
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
    NSString *url = @"get_category_names.php" ;
    NSString *apiString = [[GlobalVariable sharedInstance].webserver_address stringByAppendingString:url];
    NSURL *apiURL = [NSURL URLWithString:apiString];
    
    [self.mtable setDataSource:self] ;
    [self.mtable setDelegate:self] ;
    
    tableData1 = [[NSMutableArray alloc] init] ;
    tablePositionKind = [[NSMutableArray alloc] init] ;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:apiURL] ;
    request.requestMethod = @"POST" ;
    [request setDelegate:self] ;
    [request startAsynchronous] ;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view] ;
    [self.view addSubview:HUD] ;
    [HUD show:YES] ;

    self.mtable.contentInset = UIEdgeInsetsMake(0, 0, 140, 0);
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
        
        for ( int i = 0 ; i < dataArr.count ; i++ )
        {
            if ( [[[dataArr objectAtIndex:i] valueForKey:@"name"] length] > 0 )
            {
                [tableData1 addObject:[[dataArr objectAtIndex:i] valueForKey:@"name"]] ;
                [tablePositionKind addObject:[[dataArr objectAtIndex:i] valueForKey:@"id"]] ;
            }
        }
        
        [_mtable reloadData] ;
    }
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
    NSLog(@"%@", [request.error localizedDescription]);
}

- (NSArray *)parseDataWithDict:(NSData *)_data
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_data];
    NSMutableDictionary *fectchDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser:@"pagecontent"];
    [xmlParser setDelegate:parser];
    [xmlParser parse];
    
    [fectchDataDic setObject:parser.parsedXML forKey:@"root"];
    NSArray *dataArr=[fectchDataDic objectForKey:@"root"];
    
    return dataArr;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableData1 count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IDIOM == IPAD )
        return 60 ;
    else
        return 50 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UITableViewCell";
    UITableViewCell *cell = (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if ( IDIOM == IPAD )
            cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        else
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    cell.textLabel.text = [tableData1 objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [GlobalVariable sharedInstance].position_kind = [tablePositionKind objectAtIndex:indexPath.row] ;
    [GlobalVariable sharedInstance].category_selected = [tableData1 objectAtIndex:indexPath.row] ;
    
    [self.navigationController popViewControllerAnimated:YES] ;
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

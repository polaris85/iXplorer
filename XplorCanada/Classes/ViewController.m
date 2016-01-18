//
//  ViewController.m
//  xplor
//
//  Created by Adam on 3/3/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "ViewController.h"
#import "NLCachedImageTableViewCell.h"
#import "SplashViewController.h"

@interface ViewController ()
@end

@implementation ViewController
@synthesize bannerIsVisible, btn_Country ;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [btn_Country setContentEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)] ;
    [GlobalVariable sharedInstance].webserver_address = @"http://ixplorecanada.canadaworldapps.com/phone/" ;
    
    self.mtable.contentInset = UIEdgeInsetsMake(0, 0, 140, 0); //values passed are - top, left, bottom, right
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [GlobalVariable sharedInstance].category_selected = @"" ;
    [GlobalVariable sharedInstance].resPositions = [[NSMutableArray alloc] init] ;
    [GlobalVariable sharedInstance].resNames = [[NSMutableArray alloc] init] ;
    
    tableData1 = [[NSMutableArray alloc] init] ;
    tableCategoryTag = [[NSMutableArray alloc] init] ;
    tablePositionKind = [[NSMutableArray alloc] init] ;
    tableCategoryIcon = [[NSMutableArray alloc] init] ;
    
    tableData2 = [NSMutableArray arrayWithObjects:@"Add your business", @"Settings", nil];
    
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
    
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults] ;
    UIImage* img_Country ;
    
    if ( [[prefs objectForKey:@"country"] length] > 1 )
    {
        NSString* temp = [prefs objectForKey:@"country"] ;
        temp = [[temp lowercaseString] stringByReplacingOccurrencesOfString:@"%20" withString:@""] ;
        temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""] ;
        img_Country = [UIImage imageNamed:temp] ;
    }
    else
    {
        NSLocale *usLocale = [NSLocale currentLocale] ;
        NSString *flagFileName = [[[usLocale displayNameForKey: NSLocaleCountryCode value: [usLocale objectForKey: NSLocaleCountryCode]] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
        flagFileName = [flagFileName stringByReplacingOccurrencesOfString:@"\r" withString:@""] ;
        img_Country = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",flagFileName]] ;
    }
    
    [btn_Country setBackgroundImage:img_Country forState:UIControlStateNormal] ;
    
    NSString *url = @"get_category_names.php" ;
    NSString *apiString = [[GlobalVariable sharedInstance].webserver_address stringByAppendingString:url];
    NSURL *apiURL = [NSURL URLWithString:apiString];
    
    [self.mtable setDataSource:self] ;
    [self.mtable setDelegate:self] ;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:apiURL] ;
    request.requestMethod = @"POST" ;
    [request setDelegate:self] ;
    [request startAsynchronous] ;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view] ;
    [self.view addSubview:HUD] ;
    [HUD show:YES] ;
}

- (IBAction)onCountry:(id)sender
{
    [self performSegueWithIdentifier:@"toCountry" sender:self] ;
    
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
                if ( [[[dataArr objectAtIndex:i] valueForKey:@"tag"] length] > 1 )
                    [tableCategoryTag addObject:[[dataArr objectAtIndex:i] valueForKey:@"tag"]] ;
                else
                    [tableCategoryTag addObject:@""] ;
                if ( [[dataArr objectAtIndex:i] valueForKey:@"icon"] == nil )
                    [tableCategoryIcon addObject:@"0"] ;
                else
                    [tableCategoryIcon addObject:[[dataArr objectAtIndex:i] valueForKey:@"icon"]] ;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ( section == 0 )
        return [tableData1 count];
    else
        return [tableData2 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UITableViewCell";
    NLCachedImageTableViewCell *cell = (NLCachedImageTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell)
    {
        cell = [[NLCachedImageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if ( IDIOM == IPAD )
            cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        else
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    if ( indexPath.section == 0 )
    {
        [cell setPlaceholderImage:[UIImage imageNamed:@"User"]];
        
        
        NSString *strUri = @"http://ixplorecanada.canadaworldapps.com/images/category_icons/" ;
        if ( [[tableCategoryIcon objectAtIndex:indexPath.row] length] > 0 )
            strUri = [strUri stringByAppendingString:[tableCategoryIcon objectAtIndex:indexPath.row]];
        
        [cell setImageUrlString:strUri];
        cell.textLabel.text = [tableData1 objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [tableData2 objectAtIndex:indexPath.row];
        [cell.imageView setImage:nil] ;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
    
    if ( indexPath.section == 0 )
    {
        [GlobalVariable sharedInstance].position_kind = [tablePositionKind objectAtIndex:indexPath.row] ;
        [GlobalVariable sharedInstance].category_selected = [tableData1 objectAtIndex:indexPath.row] ;
        [GlobalVariable sharedInstance].category_selected_tag = [tableCategoryTag objectAtIndex:indexPath.row] ;
        
        [self performSegueWithIdentifier:@"toSplash" sender:self] ;
        
    }
    if ( indexPath.section == 1 )
    {
        if ( indexPath.row == 0 )
        {
            [self performSegueWithIdentifier:@"toBusiness" sender:self] ;
        }
        else if ( indexPath.row == 1 )
        {
            [self performSegueWithIdentifier:@"toSetting" sender:self] ;
        }
    }
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh-mm-ss"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    NSLog(@"Start - %@", resultString) ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ( IDIOM == IPAD )
        return 55;
    else
        return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IDIOM == IPAD )
        return 60 ;
    else
        return 50 ;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, tableView.bounds.size.width - 10, 18)] ;
    
    if ( section == 0 )
        label.text = @"Please choose what you are looking for" ;
    else
        label.text = @"General" ;

    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:(7/255.0) green:(48/255.0) blue:(110/255.0) alpha:1]];
    
    return headerView;
}

@end

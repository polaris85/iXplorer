//
//  PlaceListViewController.m
//  iXplorCanada
//
//  Created by Kang on 6/10/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "PlaceListViewController.h"
#import "../../Library/GlobalVariable.h"
#import "NLCachedImageTableViewCell.h"
#import "../Business/BusinessViewController.h"

@interface PlaceListViewController ()

@end

@implementation PlaceListViewController
@synthesize label_Title, label_BizName, label_PlaceName, txt_Description, imgBusiness, btnClose, detailView, bannerIsVisible, btnCall, btnDirection, btnShare;

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ( section == 0 )
        return [arr_featured_bussines count] + 1 ;
    else
        return [[GlobalVariable sharedInstance].table_google count] ;
        //return 60 ;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UITableViewCell";
    NLCachedImageTableViewCell *cell = (NLCachedImageTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell)
    {
        cell = [[NLCachedImageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if (IDIOM == IPAD)
            cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        else
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        
        for (UIView *tempView in cell.contentView.subviews)
             [tempView removeFromSuperview] ;
    }
    
    if ( indexPath.section == 0 )
    {
        if ( indexPath.row > 0 )
        {
            [cell setImageUrlString:[[arr_featured_bussines objectAtIndex:indexPath.row-1] valueForKey:@"icon"]];
            cell.textLabel.text = [[arr_featured_bussines objectAtIndex:indexPath.row-1] valueForKey:@"name"] ;
            cell.detailTextLabel.text = [[arr_featured_bussines objectAtIndex:indexPath.row-1] valueForKey:@"address"] ;
            
        }
        else
        {
            cell.textLabel.text = @"Place your Ad" ;
            cell.detailTextLabel.text = @"Add your business on this spot" ;
            [cell setImageUrlString:@""];
            
        }
        
    }
    else if ( indexPath.section == 1 )
    {
        [cell setImageUrlString:nil];
        
        if ( [[GlobalVariable sharedInstance].table_google count] > indexPath.row )
        {
            cell.textLabel.text = [[[GlobalVariable sharedInstance].table_google objectAtIndex:indexPath.row] valueForKey:@"name"] ;
            cell.detailTextLabel.text = [[[GlobalVariable sharedInstance].table_google objectAtIndex:indexPath.row] valueForKey:@"address"] ;
        }
    }
    
    if ( indexPath.row % 2 == 0 )
        cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] ;
    else
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] ;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ( section == 0 )
        return 45;
    else
        return 20 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IDIOM == IPAD )
        return 70 ;
    else
        return 60 ;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if ( indexPath.section == 0 )
    {
        if ( indexPath.row == 0 )
        {
            [self performSegueWithIdentifier:@"placeAddNewBussiness" sender:self] ;
        }
        else
        {
            nSelected_row = (int)indexPath.row - 1 ;
            place_phone = [[[GlobalVariable sharedInstance].resPositions objectAtIndex:(indexPath.row - 1) ] valueForKey:@"call_num"] ;
            
            if ( [place_phone length] < 1 )
                [btnCall setEnabled:NO] ;
            else
                [btnCall setEnabled:YES] ;
            
            f_FeaturedPlace = YES ;
            [self showDetailView:(int)indexPath.row - 1] ;
        }
    }
    else if ( indexPath.section == 1 )
    {
        f_FeaturedPlace = NO ;
            
            nSelected_row = (int)indexPath.row ;
            place_phone = [[[GlobalVariable sharedInstance].table_google objectAtIndex:indexPath.row] valueForKey:@"call_num"] ;
            
            if ( [place_phone length] < 1 )
                [btnCall setEnabled:NO] ;
            else
                [btnCall setEnabled:YES] ;
            
            [self showDetailView:(int)indexPath.row] ;
        
    }
}

- (void)showDetailView:(int)nIndex
{
    if ( f_FeaturedPlace )
    {
        if ( [[GlobalVariable sharedInstance].resPositions count] > nIndex )
        {
            if ( [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"name"] length] > 1 )
                [label_BizName setText:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"name"]] ;
            else
                [label_BizName setText:@"No Name"] ;
            if ( [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"address"] length] > 1 )
                [label_PlaceName setText:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"address"]] ;
            else
                [label_PlaceName setText:@"No Address"] ;
            
            if ([[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"description"] length] > 0)
                [txt_Description setText:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"description"]] ;
            else
                [txt_Description setText:@"No Description"] ;
            
            NSURL *imageURL = [NSURL URLWithString:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nIndex] valueForKey:@"icon"]];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    [imgBusiness setImage:image] ;
                });
            });
        }
        
    }
    else
    {
        if ( [[GlobalVariable sharedInstance].table_google count] > nIndex )
        {
            if ( [[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"name"] length] > 1 )
                [label_BizName setText:[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"name"]] ;
            
            if ( [[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"address"] length] > 1 )
                [label_PlaceName setText:[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"address"]] ;
            
            if ([[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"description"] length] > 0)
                [txt_Description setText:[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"description"]] ;
            
            NSString* strUri ;
            
            if ( [[[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"icon"] length] > 0 )
                strUri = [[[GlobalVariable sharedInstance].table_google objectAtIndex:nIndex] valueForKey:@"icon"] ;
            
            NSURL *imageURL = [NSURL URLWithString:strUri];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    [imgBusiness setImage:image] ;
                });
            });
        }
        
    }
    
    [UIView beginAnimations:nil context:NULL] ;
    [UIView setAnimationDuration:0.5] ;
    [detailView setAlpha:1.0] ;
    [self.mtable setAlpha:0.3] ;
    [self.view bringSubviewToFront:detailView] ;
    [UIView commitAnimations];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)] ;
    [headerView setBackgroundColor:[UIColor colorWithRed:(7/255.0) green:(48/255.0) blue:(110/255.0) alpha:1]];
    
    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, headerView.frame.origin.y, headerView.frame.size.width - 10, headerView.frame.size.height)] ;
    [sectionHeader setTextColor:[UIColor whiteColor]] ;
    if ( section == 0 )
        [sectionHeader setText:@"Featured Business"] ;
    else
        [sectionHeader setText:@""] ;
    
    [headerView addSubview:sectionHeader] ;
    return headerView;
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (IBAction)onCloseDetail:(id)sender
{
    [UIView beginAnimations:nil context:NULL] ;
    [UIView setAnimationDuration:0.5] ;
    [detailView setAlpha:0.0] ;
    [self.mtable setAlpha:1.0] ;
    [self.view bringSubviewToFront:detailView] ;
    [UIView commitAnimations];
}

- (IBAction)onShare:(id)sender
{
    NSString *temp = label_BizName.text ;
    temp = [temp stringByAppendingString:@"\n"] ;
    temp = [temp stringByAppendingString:label_PlaceName.text] ;
    temp = [temp stringByAppendingString:@"\n"] ;
    temp = [temp stringByAppendingString:txt_Description.text] ;
    temp = [temp stringByAppendingString:@"\n"] ;
    
    NSString *msg = NSLocalizedString(temp, nil);
    NSURL* url = [[NSURL alloc] initWithString:@"http://ixplorecanada.canadaworldapps.com"] ;
    
    NHCalendarEvent *calendarEvent = [self createCalendarEvent];
    NHCalendarActivity *calendarActivity = [[NHCalendarActivity alloc] init];
    calendarActivity.delegate = self;
    
    NSArray *activities = @[calendarActivity];
    
    self.activity = [[UIActivityViewController alloc] initWithActivityItems:@[msg, url, calendarEvent]
                                                      applicationActivities:activities];
    
    self.activity.excludedActivityTypes = @[
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypePrint,
                                            UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAssignToContact
                                            ];
    
    [self presentViewController:self.activity
                       animated:YES
                     completion:NULL];
}

-(NHCalendarEvent *)createCalendarEvent
{
    NHCalendarEvent *calendarEvent = [[NHCalendarEvent alloc] init];
    
    calendarEvent.title = @"Long-expected Party";
    calendarEvent.location = @"The Shire";
    calendarEvent.notes = @"Bilbo's eleventy-first birthday.";
    calendarEvent.startDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    calendarEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:calendarEvent.startDate];
    calendarEvent.allDay = NO;
    calendarEvent.URL = [NSURL URLWithString:@"http://github.com/otaviocc/NHCalendarActivity"];
    
    // Add alarm
    NSArray *alarms = @[
                        [EKAlarm alarmWithRelativeOffset:- 60.0f * 60.0f * 24],  // 1 day before
                        [EKAlarm alarmWithRelativeOffset:- 60.0f * 15.0f]        // 15 minutes before
                        ];
    calendarEvent.alarms = alarms;
    
    return calendarEvent;
}

#pragma mark - NHCalendarActivityDelegate

-(void)calendarActivityDidFinish:(NHCalendarEvent *)event
{
    NSLog(@"Event created from %@ to %@", event.startDate, event.endDate);
}

-(void)calendarActivityDidFail:(NHCalendarEvent *)event
                     withError:(NSError *)error
{
    NSLog(@"Ops!");
}

- (IBAction)onCall:(id)sender
{
    NSString* callStr = @"tel://" ;
    
    if ( [place_phone length] > 0 )
    {
        NSString* temp = @"" ;
        
        for ( int i = 0 ; i < place_phone.length ; i++ )
        {
            int n = [[place_phone substringWithRange:NSMakeRange(i, 1)] intValue] ;
            if ( n > 0 && n < 10 )
            {
                temp = [temp stringByAppendingString:[place_phone substringWithRange:NSMakeRange(i, 1)]] ;
            }
            else
            {
                NSString* temp1 = [place_phone substringWithRange:NSMakeRange(i, 1)] ;
                if ([temp1 isEqualToString:@"0"])
                    temp = [temp stringByAppendingString:@"0"] ;
            }
        }
        
        callStr = [callStr stringByAppendingString:temp] ;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callStr]];
}

- (IBAction)onMap:(id)sender
{
    float sel_lat = 0.0f ;
    float sel_lng = 0.0f ;
    
    if ( !f_FeaturedPlace )
    {
        sel_lat = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:nSelected_row] valueForKey:@"lat"] floatValue] ;
        sel_lng = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:nSelected_row] valueForKey:@"lng"] floatValue] ;
    }
    else
    {
        sel_lat = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nSelected_row] valueForKey:@"lat"] floatValue] ;
        sel_lng = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:nSelected_row] valueForKey:@"lng"] floatValue] ;
    }
    
    
    [GlobalVariable sharedInstance].lat2 = sel_lat ;
    [GlobalVariable sharedInstance].lng2 = sel_lng ;
    
    [self performSegueWithIdentifier:@"gotoMap" sender:self] ;
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
    [detailView setAlpha:0.0f] ;
    
    [label_Title setText:[GlobalVariable sharedInstance].category_selected] ;
    [self.mtable setDataSource:self] ;
    [self.mtable setDelegate:self] ;
    
    [btnClose setContentEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)] ;
    self.mtable.contentInset = UIEdgeInsetsMake(0, 0, 120, 0); //values passed are - top, left, bottom, right
    
    [_imgGoogleView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 45, [UIScreen mainScreen].bounds.size.width, 45)] ;
    
    arr_featured_bussines = [[NSMutableArray alloc] init] ;
    //[GlobalVariable sharedInstance].table_google   = [[NSMutableArray alloc] init] ;
    
    for ( int i = 0 ; i < [GlobalVariable sharedInstance].resPositions.count ; i++ )
    {
        [arr_featured_bussines addObject:[[GlobalVariable sharedInstance].resPositions objectAtIndex:i]] ;
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reload:) userInfo:nil repeats:YES];
}


-(void)reload:(NSTimer *)pTmpTimer
{
    intTmp += 1;
    
    if(intTmp <= 3)
    {
        
    }
    else
    {
        //[pTmpTimer invalidate];
        [_mtable reloadData] ;
        intTmp = 0;
    }
}

- (NSMutableArray *)parseDataWithDict:(NSData *)_data withString:(NSString*)parseString
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_data] ;
    NSMutableDictionary *fectchDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser:parseString] ;
    [xmlParser setDelegate:parser];
    [xmlParser parse];
    
    [fectchDataDic setObject:parser.parsedXML forKey:@"root"];
    NSMutableArray *dataArr=[fectchDataDic objectForKey:@"root"];
    
    return dataArr;
}

- (void)viewDidAppear:(BOOL)animated
{
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
    
    btnCall.layer.borderWidth = 1;
    btnCall.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    btnDirection.layer.borderWidth = 1;
    btnDirection.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    btnShare.layer.borderWidth = 1;
    btnShare.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    arr_google_bussines = [GlobalVariable sharedInstance].table_google ;
    //HUD = [[MBProgressHUD alloc] initWithView:self.view] ;
    //[self.view addSubview:HUD] ;
    //[HUD show:YES] ;
    
    //arr_google_bussines = [[NSMutableArray alloc] init] ;
    //[self LoadGooglePositions] ;
}

- (void)LoadGooglePositions
{
    for ( int i = 0 ; i < [GlobalVariable sharedInstance].table_references.count ; i++ )
    {
        NSString* reference = [[[GlobalVariable sharedInstance].table_references objectAtIndex:i] valueForKey:@"reference"] ;
        NSString* url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/xml?reference=%@&sensor=false&key=%@", reference, kGOOGLE_API_KEY] ;
        
        __weak ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]]  ;
        request.requestMethod = @"POST" ;
        [request setCompletionBlock:^{
            
            if ( request != nil )
            {
                int statusCode = [request responseStatusCode] ;
                if (statusCode == 200) {
                    NSString * responseString = [request responseString] ;
                    responseString = [responseString stringByReplacingOccurrencesOfString:@"&" withString:@" "] ;
                    NSMutableArray  *dataArr =  [self parseDataWithDict:[responseString dataUsingEncoding:NSUTF8StringEncoding] withString:@"result"] ;
                    
                    for ( int i = 0 ; i < dataArr.count ; i++ )
                    {
                        NSMutableDictionary* temp = [[NSMutableDictionary alloc] initWithCapacity:8] ;
                        
                        [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"name"] forKey:@"name"] ;
                        [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"vicinity"] forKey:@"address"] ;
                        [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"icon"] forKey:@"icon"] ;
                        [temp setObject:@"-1" forKey:@"kind"] ;
                        [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"lat"] forKey:@"lat"] ;
                        [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"lng"] forKey:@"lng"] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"formatted_phone_number"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"formatted_phone_number"] forKey:@"call_num"] ;
                        
                        NSString* _description = [NSString stringWithFormat:@" Address %@\n Phone Number %@\n International Phone Number %@\n Website %@",
                                                  [[dataArr objectAtIndex:i] valueForKey:@"formatted_address"],
                                                  [[dataArr objectAtIndex:i] valueForKey:@"formatted_phone_number"],
                                                  [[dataArr objectAtIndex:i] valueForKey:@"international_phone_number"],
                                                  [[dataArr objectAtIndex:i] valueForKey:@"url"]];
                        
                        [temp setObject:_description forKey:@"description"] ;
                        
                        [arr_google_bussines addObject:temp] ;
                        [_mtable reloadData] ;
                    }
                }
            }
            
            [HUD show:NO] ;
            [HUD removeFromSuperview];
        }];
        
        [request setFailedBlock:^{
            [HUD show:NO] ;
            [HUD removeFromSuperview];
        }];
        
        [request startAsynchronous] ;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        if ( banner.frame.origin.y == [UIScreen mainScreen].bounds.size.height )
        {
            if ( IDIOM == IPAD )
            {
                banner.frame = CGRectOffset(banner.frame, 0, -65);
                _imgGoogleView.frame = CGRectOffset(banner.frame, 0, -65) ;
            }
            else
            {
                banner.frame = CGRectOffset(banner.frame, 0, -50);
                _imgGoogleView.frame = CGRectOffset(banner.frame, 0, -50) ;
            }
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

@end

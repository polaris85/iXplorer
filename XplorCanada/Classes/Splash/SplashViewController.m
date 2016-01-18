//
//  SplashViewController.m
//  iXplorCanada
//
//  Created by Adam on 3/11/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "SplashViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GlobalVariable.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize waiter,desription ;

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
	
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    [waiter startAnimating];
    [desription setText:@"Please wait..."] ;
    
    [GlobalVariable sharedInstance].resPositions = [[NSMutableArray alloc] init] ;
    [GlobalVariable sharedInstance].table_references = [[NSMutableArray alloc] init] ;

    [self getGoogleReferences] ;
}

-(void) getFeaturedBusiness
{
    NSString* url = @"http://ixplorecanada.canadaworldapps.com/locations.php" ;
    __weak ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:
                                          [NSURL URLWithString:url]] ;
    
    [request addPostValue:[GlobalVariable sharedInstance].position_kind forKey:@"kind"] ;
    request.requestMethod = @"POST" ;
    
    [request setCompletionBlock:^{
        
        int statusCode = [request responseStatusCode] ;
        if (statusCode == 200) {
            NSString * responseString = [request responseString] ;
            responseString = [responseString stringByReplacingOccurrencesOfString:@"&" withString:@" "] ;
            NSMutableArray  *dataArr =  [self parseDataWithDict:[responseString dataUsingEncoding:NSUTF8StringEncoding] withString:@"pagecontent"] ;
            if ([dataArr count] > 0) {
                [GlobalVariable sharedInstance].resPositions = dataArr ;
            }
        }
        
        [self getCurrentLocationReferences] ;

    }];
    
    [request setFailedBlock:^{
        [self getCurrentLocationReferences] ;
    }];
    
    [request startAsynchronous] ;
}

- (void)getGoogleReferences
{
    NSLocale *usLocale = [NSLocale currentLocale] ;
    NSString *flagFileName = [[[usLocale displayNameForKey: NSLocaleCountryCode value: [usLocale objectForKey: NSLocaleCountryCode]] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults] ;
    
    if ( [[prefs valueForKey:@"country"] length] < 1 || [[[[prefs valueForKey:@"country"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"" ] isEqualToString:flagFileName] )
        [self getFeaturedBusiness] ;
    else
        [self getOtherCountryReferences] ;
}

- (void)getCurrentLocationReferences
{
    NSString* url = @"http://ixplorecanada.canadaworldapps.com/phone/google_place.php" ;
    __weak ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:url]] ;
    
    [request addPostValue:latitude                                                                              forKey:@"lat"] ;
    [request addPostValue:longitude                                                                             forKey:@"lng"] ;
    [request addPostValue:[[GlobalVariable sharedInstance].category_selected_tag lowercaseString]               forKey:@"types"] ;
    [request addPostValue:[NSString stringWithFormat:@"%f", 20000.0]                                            forKey:@"radius"] ;
    [request addPostValue:kGOOGLE_API_KEY                                                                       forKey:@"key"] ;
    [request addPostValue:[GlobalVariable sharedInstance].position_kind                                         forKey:@"kind"] ;
    
    request.requestMethod = @"POST" ;
    
    [request setCompletionBlock:^{
        
        int statusCode = [request responseStatusCode] ;
        if (statusCode == 200) {
            NSString * responseString = [[request responseString] stringByReplacingOccurrencesOfString:@"&" withString:@" "] ;
            //[GlobalVariable sharedInstance].table_references = [self parseDataWithDict:[responseString dataUsingEncoding:NSUTF8StringEncoding] withString:@"pagecontent"] ;
            
            NSMutableArray* dataArr = [self parseDataWithDict:[responseString dataUsingEncoding:NSUTF8StringEncoding] withString:@"pagecontent"] ;
            NSMutableArray* _temp_references = [[NSMutableArray alloc] init] ;
            
            for ( int i = 0 ; i < dataArr.count ; i++ )
            {
                if ( ![_temp_references containsObject:[dataArr objectAtIndex:i]] )
                {
                    [_temp_references addObject:[dataArr objectAtIndex:i]] ;
                    
                    NSLog(@" %d - %@ \n", i, [[dataArr objectAtIndex:i] valueForKey:@"reference"]) ;
                }
            }
            
            [GlobalVariable sharedInstance].table_references = _temp_references ;
        }
        
        [waiter stopAnimating];
        [self performSegueWithIdentifier:@"toCamera" sender:self];
    }];
    
    [request setFailedBlock:^{
        [waiter stopAnimating];
        [self performSegueWithIdentifier:@"toCamera" sender:self];
    }];
    
    [request startAsynchronous] ;
}

- (void)getOtherCountryReferences
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults] ;
    NSString* temp = [[GlobalVariable sharedInstance].category_selected_tag lowercaseString] ;
    
    temp = [temp stringByAppendingString:@"+in+"] ;
    temp = [temp stringByAppendingString:[prefs valueForKey:@"country"]] ;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@"%20"] ;
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""] ;
    
    NSString* url = @"http://ixplorecanada.canadaworldapps.com/phone/google_place_country.php" ;
    __weak ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]] ;
    [request addPostValue:temp forKey:@"query"] ;
    [request addPostValue:[GlobalVariable sharedInstance].position_kind forKey:@"kind"] ;
    [request addPostValue:kGOOGLE_API_KEY                               forKey:@"key"] ;
    
    request.requestMethod = @"POST" ;
    [request setCompletionBlock:^{
        int statusCode = [request responseStatusCode] ;
        if (statusCode == 200) {
            NSString * responseString = [[request responseString] stringByReplacingOccurrencesOfString:@"&" withString:@" "] ;
            [GlobalVariable sharedInstance].table_references =  [self parseDataWithDict:[responseString dataUsingEncoding:NSUTF8StringEncoding] withString:@"pagecontent"] ;
        }
        
        [waiter stopAnimating];
        [self performSegueWithIdentifier:@"toCamera" sender:self];
        
    }];
    
    [request setFailedBlock:^{
        [waiter stopAnimating];
        [self performSegueWithIdentifier:@"toCamera" sender:self];
    }];
    
    [request startAsynchronous] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)parseDataWithDict:(NSData *)_data withString:(NSString*)parseString
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_data];
    NSMutableDictionary *fectchDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser:parseString];
    [xmlParser setDelegate:parser];
    [xmlParser parse];
    
    [fectchDataDic setObject:parser.parsedXML forKey:@"root"];
    NSMutableArray *dataArr=[fectchDataDic objectForKey:@"root"];
    
    return dataArr;
}


@end

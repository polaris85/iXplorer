//
//  LocationMapViewController.m
//  xplor
//
//  Created by Adam on 3/5/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "LocationMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GlobalVariable.h"
#import "Place.h"
#import "PlaceAnnotation.h"

NSString * const kNameKey = @"name";
NSString * const kReferenceKey = @"reference";
NSString * const kAddressKey = @"vicinity";
NSString * const kLatiudeKeypath = @"geometry.location.lat";
NSString * const kLongitudeKeypath = @"geometry.location.lng";

@interface LocationMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@end

@implementation LocationMapViewController
@synthesize bannerIsVisible, mapView, locationManager, posLocations, btnBack, btnDirection ;

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
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
    CGRect adFrame = adView.frame;
    adFrame.origin.y = self.view.frame.size.height-adView.frame.size.height+50;
    adView.frame = adFrame;
    
    [super viewDidLoad];
    
    [btnBack        setContentEdgeInsets:UIEdgeInsetsMake(-20.0, -20.0, -20.0, -20.0)] ;
    [btnDirection setFrame:CGRectMake(btnDirection.frame.origin.x, [UIScreen mainScreen].bounds.size.height, btnDirection.frame.size.width, 45)] ;
    [btnDirection   setContentEdgeInsets:UIEdgeInsetsMake(-40.0, -40.0, -40.0, -40.0)] ;

    UIColor * background = [UIColor colorWithRed:0.43137f green:0.8f blue:0.94118 alpha:1.0f];
    [self.view setBackgroundColor:background] ;
    
    locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    mapView.delegate = self;
    
    for ( int i = 0 ; i < [GlobalVariable sharedInstance].resPositions.count ; i++ )
    {
        float lat = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"lat"] floatValue] ;
        float lng = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"lng"] floatValue] ;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
        
        Place *currentPlace = [[Place alloc] initWithLocation:location reference:nil name:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"name"] address:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"address"]];
        
        [currentPlace setValue:[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] forKey:@"description"] ;
        
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
        [mapView addAnnotation:annotation];
    }
    
    for ( int i = 0 ; i < [GlobalVariable sharedInstance].table_google.count ; i++ )
    {
        float lat = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"lat"] floatValue] ;
        float lng = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"lng"] floatValue] ;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
        
        Place *currentPlace = [[Place alloc] initWithLocation:location reference:nil name:[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"name"] address:[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"address"]];
        
        [currentPlace setLatitude:[NSString stringWithFormat:@"%f", lat]] ;
        [currentPlace setLongitude:[NSString stringWithFormat:@"%f", lng]] ;
        
        [currentPlace setValue:[[GlobalVariable sharedInstance].table_google objectAtIndex:i] forKey:@"description"] ;
        
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
        [mapView addAnnotation:annotation];
    }
    
    [btnDirection setFrame:CGRectMake(btnDirection.frame.origin.x, [UIScreen mainScreen].bounds.size.height, btnDirection.frame.size.width, 50)] ;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reload:) userInfo:nil repeats:YES];
}

-(void)reload:(NSTimer *)pTmpTimer
{
    intTmp += 1;
    
    if(intTmp <= 5)
    {
        
        
    }
    else
    {
        //[pTmpTimer invalidate];
        
        NSInteger toRemoveCount = mapView.annotations.count;
        NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:toRemoveCount];
        for (id annotation in mapView.annotations)
            if (annotation != mapView.userLocation)
                [toRemove addObject:annotation];
        [mapView removeAnnotations:toRemove];
        
        for ( int i = 0 ; i < [GlobalVariable sharedInstance].table_google.count ; i++ )
        {
            float lat = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"lat"] floatValue] ;
            float lng = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"lng"] floatValue] ;
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
            
            Place *currentPlace = [[Place alloc] initWithLocation:location reference:nil name:[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"name"] address:[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"address"]];
            
            [currentPlace setLatitude:[NSString stringWithFormat:@"%f", lat]] ;
            [currentPlace setLongitude:[NSString stringWithFormat:@"%f", lng]] ;
            
            [currentPlace setValue:[[GlobalVariable sharedInstance].table_google objectAtIndex:i] forKey:@"description"] ;
            
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
            [mapView addAnnotation:annotation];
        }
        
        for ( int i = 0 ; i < [GlobalVariable sharedInstance].resPositions.count ; i++ )
        {
            float lat = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"lat"] floatValue] ;
            float lng = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"lng"] floatValue] ;
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
            
            Place *currentPlace = [[Place alloc] initWithLocation:location reference:nil name:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"name"] address:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"address"]];
            
            [currentPlace setValue:[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] forKey:@"description"] ;
            
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
            [mapView addAnnotation:annotation];
        }
        
        [mapView setRegion:mapView.region animated:TRUE];
        mapView.showsUserLocation = NO ;
        
        intTmp = 0;
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [btnDirection setAlpha:1.0] ;
    [btnDirection setFrame:CGRectMake(btnDirection.frame.origin.x, [UIScreen mainScreen].bounds.size.height - 50, btnDirection.frame.size.width, 50)] ;
    
    [UIView commitAnimations];
    
    [GlobalVariable sharedInstance].lat1 = locationManager.location.coordinate.latitude ;
    [GlobalVariable sharedInstance].lng1 = locationManager.location.coordinate.longitude ;
    
    [GlobalVariable sharedInstance].lat2 = [view.annotation coordinate].latitude ;
    [GlobalVariable sharedInstance].lng2 = [view.annotation coordinate].longitude ;
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [btnDirection setAlpha:0.0] ;
    [btnDirection setFrame:CGRectMake(btnDirection.frame.origin.x, [UIScreen mainScreen].bounds.size.height, btnDirection.frame.size.width, 50)] ;
    
    [UIView commitAnimations];
}

- (IBAction)onGetDirection:(id)sender
{
    [self performSegueWithIdentifier:@"mapDistance" sender:self] ;
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *lastLocation = [locations lastObject];
	
	CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
	float a = lastLocation.coordinate.latitude ;
    float b = lastLocation.coordinate.longitude ;
    
	if(accuracy < 100.0) {
		MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
        
        if ( [[GlobalVariable sharedInstance].table_google count] > 0 )
        {
            float lat = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:0] valueForKey:@"lat"] floatValue] ;
            float lng = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:0] valueForKey:@"lng"] floatValue] ;
            
            CLLocationCoordinate2D temp = CLLocationCoordinate2DMake(lat, lng) ;
            
            MKCoordinateRegion region = MKCoordinateRegionMake(temp, span);
            [mapView setRegion:region animated:YES];
        }
        
		for ( int i = 0 ; i < [GlobalVariable sharedInstance].resPositions.count ; i++ )
        {
            float lat = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"lat"] floatValue] ;
            float lng = [[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"lng"] floatValue] ;
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
            
            Place *currentPlace = [[Place alloc] initWithLocation:location reference:nil name:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"name"] address:[[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] valueForKey:@"address"]];
            
            [currentPlace setValue:[[GlobalVariable sharedInstance].resPositions objectAtIndex:i] forKey:@"description"] ;
            
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
            [mapView addAnnotation:annotation];
        }
        
        for ( int i = 0 ; i < [GlobalVariable sharedInstance].table_google.count ; i++ )
        {
            float lat = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"lat"] floatValue] ;
            float lng = [[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"lng"] floatValue] ;
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
            
            Place *currentPlace = [[Place alloc] initWithLocation:location reference:nil name:[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"name"] address:[[[GlobalVariable sharedInstance].table_google objectAtIndex:i] valueForKey:@"address"]];
            
            [currentPlace setLatitude:[NSString stringWithFormat:@"%f", lat]] ;
            [currentPlace setLongitude:[NSString stringWithFormat:@"%f", lng]] ;
            
            [currentPlace setValue:[[GlobalVariable sharedInstance].table_google objectAtIndex:i] forKey:@"description"] ;
            
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
            [mapView addAnnotation:annotation];
        }
		
        mapView.showsUserLocation = NO ;
        [manager stopUpdatingLocation];
	}
    
    NSLog(@"%f, %f", a,b) ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES] ;
}

- (void) discardLocationManager
{
    locationManager.delegate = nil;
}

@end

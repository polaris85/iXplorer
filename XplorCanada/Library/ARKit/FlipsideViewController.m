//
//  FlipsideViewController.m
//  Around Me
//
//  Created by Jean-Pierre Distler on 30.01.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import "FlipsideViewController.h"

#import "Place.h"
#import "PlacesLoader.h"
#import "MarkerView.h"
#import "PlaceAnnotation.h"

NSString * const kPhoneKey = @"formatted_phone_number";
NSString * const kWebsiteKey = @"website";

const int kInfoViewTag = 1001;

@interface FlipsideViewController () <MarkerViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AugmentedRealityController *arController;
@property (nonatomic, strong) NSMutableArray *geoLocations;
@end


@implementation FlipsideViewController

-(IBAction)done:(id)sender
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

	if(!_arController) {
		_arController = [[AugmentedRealityController alloc] initWithView:[self view] parentViewController:self withDelgate:self];
	}
    
    [_arController setMinimumScaleFactor:0.5];
	[_arController setScaleViewsBasedOnDistance:YES];
	[_arController setRotateViewsBasedOnPerspective:YES];
	[_arController setDebugMode:NO];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass.png"]];
    [background setFrame:CGRectMake(0, 0, 100, 100)];
    
    compass = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 100, 100)] ;
    compass.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [compass addSubview:background];
    [compass sendSubviewToBack:compass] ;
    
    [self.view addSubview:compass];
    
    for ( int i = 0 ; i < _locations.count ; i++ )
    {
        circleView[i] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point.png"]];
        [circleView[i] setFrame:CGRectMake(0, 0, 10, 10)];
        
        CGPoint saveCenter = circleView[i].center;
        CGRect newFrame = CGRectMake(circleView[i].frame.origin.x, circleView[i].frame.origin.y, 10, 10);
        circleView[i].frame = newFrame;
        circleView[i].layer.cornerRadius = 10 / 2.0;
        circleView[i].center = saveCenter;
        
        [self.view addSubview:circleView[i]] ;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDelegate:self];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[_locationManager startUpdatingLocation];
    
}

- (void)viewWillAppear:(BOOL)animated {
	[self generateGeoLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)goMap:(id)sender
{
    _geoLocations = nil ;
    _locations = nil;
    _userLocation = nil;
    
    [self performSegueWithIdentifier:@"toMap" sender:self] ;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *lastLocation = [locations lastObject];
	CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
	
	if(accuracy < 100.0) {
        int i = 0 ;
        for(Place *place in _locations) {
            ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:[place location] locationTitle:[place placeName]];
            [coordinate calibrateUsingOrigin:[_locationManager location]];
            MarkerView *markerView = [[MarkerView alloc] initWithCoordinate:coordinate delegate:self];
            NSLog(@"Marker view %@", markerView);
            
            float distance = [coordinate distanceFromOrigin] ;
            float angle = [coordinate angleFromCoordinate:_locationManager.location.coordinate  toCoordinate:[place location].coordinate] ;
            
            circleView[i].center = CGPointMake(50 + cos(angle)*distance/30, 100 - sin(angle)*distance/30);
            
            i++ ;
        }
    }
}
- (void)generateGeoLocations {
	[self setGeoLocations:[NSMutableArray arrayWithCapacity:[_locations count]]];
	int i = 0 ;
	for(Place *place in _locations) {
		ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:[place location] locationTitle:[place placeName]];
        [coordinate setIcon:[place icon] ] ;
		[coordinate calibrateUsingOrigin:[_userLocation location]];
		MarkerView *markerView = [[MarkerView alloc] initWithCoordinate:coordinate delegate:self];
		NSLog(@"Marker view %@", markerView);
		
        [coordinate setDisplayView:markerView];
		[_arController addCoordinate:coordinate];
		[_geoLocations addObject:coordinate];
	}
    
    NSLog(@"Total count : %d", i) ;
}

#pragma mark - ARLocationDelegate

-(NSMutableArray *)geoLocations {
	if(!_geoLocations) {
		[self generateGeoLocations];
	}
	return _geoLocations;
}

- (void)locationClicked:(ARGeoCoordinate *)coordinate {
	NSLog(@"Tapped location %@", coordinate);
}

#pragma mark - ARDelegate

-(void)didUpdateHeading:(CLHeading *)newHeading {
	
}

-(void)didUpdateLocation:(CLLocation *)newLocation {
	
}

-(void)didUpdateOrientation:(UIDeviceOrientation)orientation {
	
}

#pragma mark - ARMarkerDelegate

-(void)didTapMarker:(ARGeoCoordinate *)coordinate {
}

- (void)didTouchMarkerView:(MarkerView *)markerView {
	ARGeoCoordinate *tappedCoordinate = [markerView coordinate];
	CLLocation *location = [tappedCoordinate geoLocation];
	
	int index = (int)[_locations indexOfObjectPassingTest:^(Place *obj, NSUInteger index, BOOL *stop) {
        return [[obj location] isEqual:location];
    }];
	
	if(index != (int)NSNotFound) {
		Place *tappedPlace = [_locations objectAtIndex:index];
		[[PlacesLoader sharedInstance] loadDetailInformation:tappedPlace successHanlder:^(NSDictionary *response) {
			NSLog(@"Response: %@", response);
            //NSDictionary *resultDict = [response objectForKey:@"result"];
            
            for(NSDictionary *resultsDict in response)
            {
                [tappedPlace setPhoneNumber:[resultsDict objectForKey:@"call_num"]];
                [tappedPlace setDescription:[resultsDict objectForKey:@"description"]];
                [tappedPlace setAddress:[resultsDict objectForKey:@"name"]];
                [tappedPlace setLatitude:[resultsDict objectForKey:@"latitude"]];
                [tappedPlace setLongitude:[resultsDict objectForKey:@"longitude"]];
            }
            
            
			[self showInfoViewForPlace:tappedPlace];
		} errorHandler:^(NSError *error) {
			NSLog(@"Error: %@", error);
		}];
	}
}

- (void)showInfoViewForPlace:(Place *)place {
	CGRect frame = [[self view] frame];
	UITextView *infoView = [[UITextView alloc] initWithFrame:CGRectMake(50.0f, 50.0f, frame.size.width - 100.0f, frame.size.height - 100.0f)];
	[infoView setCenter:[[self view] center]];
	[infoView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	[infoView setText:[place infoText]];
	[infoView setTag:kInfoViewTag];
	//[infoView setEditable:NO];
	[[self view] addSubview:infoView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UIView *infoView = [[self view] viewWithTag:kInfoViewTag];
	
	[infoView removeFromSuperview];	
}

@end

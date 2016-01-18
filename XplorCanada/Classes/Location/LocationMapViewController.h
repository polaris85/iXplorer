//
//  LocationMapViewController.h
//  xplor
//
//  Created by Adam on 3/5/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <iAd/iAd.h>

@interface LocationMapViewController : UIViewController<CLLocationManagerDelegate,ADBannerViewDelegate, MKMapViewDelegate>
{
    ADBannerView *adView ;
    BOOL bannerIsVisible ;
    UIStoryboard *storyBoard ;
    NSInteger intTmp ;

}

@property (nonatomic,assign) BOOL                   bannerIsVisible ;
@property (strong,nonatomic) IBOutlet MKMapView *   mapView ;
@property (nonatomic, strong) CLLocationManager *   locationManager ;
@property (nonatomic, strong) NSArray *             posLocations ;
@property (nonatomic, strong) IBOutlet UIButton *   btnBack ;
@property (nonatomic, strong) IBOutlet UIButton *   btnDirection ;

- (IBAction)done:(id)sender;

@end

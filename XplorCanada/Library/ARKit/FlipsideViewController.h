//
//  FlipsideViewController.h
//  Around Me
//
//  Created by Jean-Pierre Distler on 30.01.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import "ARKit.h"


@interface FlipsideViewController : UIViewController <CLLocationManagerDelegate, ARLocationDelegate, ARDelegate, ARMarkerDelegate>
{
    UIView *compass;
    UIView *circleView[100] ;
    CGPoint delta;
    CGPoint translation;
}

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) MKUserLocation *userLocation;

- (IBAction)done:(id)sender;
- (IBAction)goMap:(id)sender;

@end

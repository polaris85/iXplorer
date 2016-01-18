//
//  SplashViewController.h
//  iXplorCanada
//
//  Created by Adam on 3/11/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "pARkViewController.h"
#import "ASIFormDataRequest.h"
#import "XMLParser.h"
#import "NSData+Base64.h"
#import "ViewController.h"
#import "../../Library/Webservice/upload/ASIHTTPRequest/ASINetworkQueue.h"

#define kGOOGLE_API_KEY @"AIzaSyDyWCoV5_luhS16_S3_ARn5qA29t8_k-V8"

@interface SplashViewController : UIViewController<CLLocationManagerDelegate, NSXMLParserDelegate>
{
    CLLocationManager *locationManager;
    NSString *latitude ;
    NSString *longitude ;
    
    int nNextSearch ;
    int nFailedRequest ;
    
    NSMutableArray* table_google ;
    
    int n_kind_detail_queue ;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waiter ;
@property (nonatomic, retain) IBOutlet UILabel* desription ;
@property (retain) ASINetworkQueue *networkQueue;

@end

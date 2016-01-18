//
//  GlobalVariable.h
//  TCM
//
//  Created by Adam on 12/27/13.
//  Copyright (c) 2013 com.appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


@interface GlobalVariable : NSObject

@property (nonatomic) int url_google_privacy_kind;
@property (nonatomic, retain) NSString* webserver_address;

@property (nonatomic, retain) NSString* businessName;
@property (nonatomic, retain) NSString* businessEmail;
@property (nonatomic, retain) NSString* businessPhone;

@property (nonatomic, retain) NSString* position_kind;
@property (nonatomic, retain) NSString* business_id;
@property (nonatomic, retain) NSString* business_icon_name;

@property (nonatomic, retain) NSMutableArray* resPositions;
@property (nonatomic, retain) NSMutableArray* table_references;
@property (nonatomic, retain) NSMutableArray* table_google;
@property (nonatomic, retain) NSMutableArray* resNames;

@property (nonatomic) float range ;
@property (nonatomic) float lat1 ;
@property (nonatomic) float lng1 ;
@property (nonatomic) float lat2 ;
@property (nonatomic) float lng2 ;

@property (nonatomic, retain) NSString* category_selected;
@property (nonatomic, retain) NSString* category_selected_tag;
+ (GlobalVariable *)sharedInstance;
@end
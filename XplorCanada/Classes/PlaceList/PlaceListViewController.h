//
//  PlaceListViewController.h
//  iXplorCanada
//
//  Created by Kang on 6/10/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "NHCalendarActivity.h"
#import "ASIHTTPRequest.h"
#import "GlobalVariable.h"
#import "XMLParser.h"
#import "NSData+Base64.h"
#import "MBProgressHUD.h"

#define kGOOGLE_API_KEY @"AIzaSyDyWCoV5_luhS16_S3_ARn5qA29t8_k-V8"

@interface PlaceListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate, NHCalendarActivityDelegate, NSXMLParserDelegate>
{
    UIStoryboard* storyboard ;
    ADBannerView *adView;
    BOOL bannerIsVisible;
    
    NSString* place_phone ;
    NSString* place_name ;
    NSString* place_address ;
    NSString* place_description ;
    
    int nSelected_row ;
    BOOL f_FeaturedPlace ;
    
    NSMutableArray* arr_featured_bussines ;
    NSMutableArray* arr_google_bussines ;
    
    MBProgressHUD* HUD ;
    NSInteger intTmp ;
}

@property (nonatomic,assign) BOOL bannerIsVisible;
@property (strong, nonatomic) UIActivityViewController*     activity ;
@property (strong, nonatomic) IBOutlet UIView*     imgGoogleView ;

- (IBAction)onBack:(id)sender ;
- (IBAction)onCloseDetail:(id)sender ;

- (IBAction)onShare:(id)sender ;
- (IBAction)onCall:(id)sender ;
- (IBAction)onMap:(id)sender ;

@property (nonatomic, retain) IBOutlet UITableView*         mtable ;
@property (nonatomic, retain) IBOutlet UILabel*             label_Title ;

@property (nonatomic, retain) IBOutlet UIView*              detailView ;
@property (nonatomic, retain) IBOutlet UILabel*             label_BizName ;
@property (nonatomic, retain) IBOutlet UILabel*             label_PlaceName ;
@property (nonatomic, retain) IBOutlet UITextView*          txt_Description ;

@property (nonatomic, retain) IBOutlet UIImageView*         imgBusiness ;
@property (nonatomic, retain) IBOutlet UIButton*            btnClose ;

@property (nonatomic, retain) IBOutlet UIButton*            btnCall ;
@property (nonatomic, retain) IBOutlet UIButton*            btnDirection ;
@property (nonatomic, retain) IBOutlet UIButton*            btnShare ;


@end

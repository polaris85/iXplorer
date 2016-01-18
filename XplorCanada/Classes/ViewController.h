//
//  ViewController.h
//  XplorCanada
//
//  Created by Adam on 3/7/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "XMLParser.h"
#import "NSData+Base64.h"
#import "GlobalVariable.h"
#import "SplashViewController.h"
#import <iAd/iAd.h>
#import "Countries.h"
#import "LandingPage/LandingViewController.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>
{
    NSMutableArray *tableData1;
    NSMutableArray *tableData2;
    NSMutableArray *tablePositionKind;
    NSMutableArray *tableCategoryIcon;
    NSMutableArray *tableCategoryTag;
    MBProgressHUD* HUD ;
    
    ADBannerView *adView;
    BOOL bannerIsVisible;
    UIStoryboard *storyBoard ;
}

@property (nonatomic,assign) BOOL bannerIsVisible;
@property (nonatomic, retain) IBOutlet UITableView* mtable ;
@property (nonatomic, retain) IBOutlet UIButton* btn_Country ;
@end

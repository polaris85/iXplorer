//
//  SelectCategoryViewController.h
//  iXplorCanada
//
//  Created by Kang on 6/13/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalVariable.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "XMLParser.h"
#import "NSData+Base64.h"
#import <iAd/iAd.h>
#import "BusinessViewController.h"

@interface SelectCategoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>
{
    NSMutableArray *tableData1;
    NSMutableArray *tablePositionKind ;
    MBProgressHUD* HUD ;
    
    ADBannerView *adView;
    BOOL bannerIsVisible;
    UIStoryboard *storyBoard ;
}

@property (nonatomic,assign) BOOL bannerIsVisible;
@property (nonatomic, retain) IBOutlet UITableView* mtable ;
-(IBAction)onReturn:(id)sender;

@end

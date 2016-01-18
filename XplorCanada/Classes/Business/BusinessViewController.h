//
//  BusinessViewController.h
//  xplor
//
//  Created by Adam on 3/3/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface BusinessViewController : UIViewController<UITextFieldDelegate,CLLocationManagerDelegate>
{
    MBProgressHUD* HUD ;
    CLLocationManager *locationManager ;
    NSString *lattitudeStr ;
    NSString *longitudeStr ;
    NSMutableArray *menuItems ;
    
    NSMutableArray* category_ids ;
    NSMutableArray* category_names ;
}

@property (nonatomic, retain) IBOutlet UITextField* txtName;
@property (nonatomic, retain) IBOutlet UITextField* txtEmail;
@property (nonatomic, retain) IBOutlet UITextField* txtPhoneNumber;
@property (nonatomic, retain) IBOutlet UITextField* txtBizName;
@property (nonatomic, retain) IBOutlet UISwitch*    swh_featured;

@property (nonatomic, retain) IBOutlet UIButton* btnBizCategory;
@property (nonatomic, retain) IBOutlet UIScrollView* container;
-(IBAction)onSubmit:(id)sender;
-(IBAction)txtDone:(id)sender;

-(IBAction)onReturn:(id)sender;
@end

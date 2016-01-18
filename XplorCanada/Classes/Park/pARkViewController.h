#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARGeoCoordinate.h"
#import "PlaceOfInterest.h"
#import "ARView.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalVariable.h"
#import "ROllLabel.h"
#import "math.h"
#import "NHCalendarActivity.h"
#import <AddressBook/AddressBook.h>
#import "../ViewController.h"
#import "ARMenuViewController.h"
#import "ASINetworkQueue.h"
#define RADIUS 50.0 

@interface pARkViewController : UIViewController<CLLocationManagerDelegate, NHCalendarActivityDelegate>
{
    
    float cur_lat ;
    float cur_lng ;
    
    NSMutableArray *                                        placesOfInterest ;
    NSMutableArray *                                        table_infos ;
    CLLocationManager *                                     locationManager;
    CLLocationDirection                                     currentHeading;
    
    int                                                     k ; // For Direction
    int                                                     k2 ;    // For info view
    UILabel *                                               titleLabel;
    UILabel *                                               msgLabel;
    ARMenuViewController *                                  msgVC ;
    NSString *                                              strPhoneNum ;
    dispatch_queue_t someQueue ;
}

//  Detail View
@property (assign, nonatomic) IBOutlet UIView*              detailView ;

@property (nonatomic, retain) IBOutlet UIImageView*         imgBizType ;
@property (nonatomic, retain) IBOutlet UIImageView*         imgCloseDetail ;

@property (assign, nonatomic) IBOutlet UILabel*             label_bizName ;
@property (assign, nonatomic) IBOutlet UILabel*             label_placeName ;

@property (assign, nonatomic) IBOutlet UITextView*          txt_description ;

@property (assign, nonatomic) IBOutlet UIButton*            btnCall ;
@property (assign, nonatomic) IBOutlet UIButton*            btnDirection ;
@property (assign, nonatomic) IBOutlet UIButton*            btnShare ;

//  Compass

@property (strong, nonatomic) UIActivityViewController*     activity ;
@property (nonatomic, retain) CLLocationManager*            locationManager;
@property (nonatomic, retain) IBOutlet UIScrollView*        compassView ;
@property (nonatomic, retain) IBOutlet UIImageView*         compassImageView ;

@property (nonatomic)                  CLLocationDirection  currentHeading;
@property (nonatomic)                  float                range ;

@property (assign, nonatomic) IBOutlet UILabel*             sliderDistance ;
@property (assign, nonatomic) IBOutlet UISlider*            slider ;

@property (nonatomic,retain)  UIButton*                     btnShowMenu ;
@property (nonatomic,retain)  IBOutlet UIButton*            btnBack ;

- (IBAction)onSliderChange:(id)sender;
- (IBAction)onCall:(id)sender;
- (IBAction)onDirection:(id)sender;
- (IBAction)onShare:(id)sender;

@end

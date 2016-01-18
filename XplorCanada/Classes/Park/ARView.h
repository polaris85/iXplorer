#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "../../Library/GlobalVariable.h"

@interface ARView : UIView  <CLLocationManagerDelegate> {
}

@property (nonatomic, retain) NSArray *placesOfInterest;

- (void)start;
- (void)stop;

@end

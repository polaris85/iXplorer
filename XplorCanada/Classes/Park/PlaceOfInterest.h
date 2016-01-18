
#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface PlaceOfInterest : NSObject


@property (nonatomic, retain) UIView *view;

@property int fshow;
@property (nonatomic, retain) CLLocation *poi_location;

+ (PlaceOfInterest *)placeOfInterestWithView:(UIView *)view at:(CLLocation *)location show:(int)fshow;

@end

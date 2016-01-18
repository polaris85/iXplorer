
#import "PlaceOfInterest.h"

@implementation PlaceOfInterest

@synthesize view;
@synthesize poi_location;

- (id)init
{
    self = [super init];
    if (self) {
			view = nil;
			poi_location = nil;
            _fshow = 1 ;
    }
    return self;
}

- (void)dealloc
{
	[view release];
	[poi_location release];
	[super dealloc];
}

+ (PlaceOfInterest *)placeOfInterestWithView:(UIView *)view at:(CLLocation *)location show:(int)fshow
{
	PlaceOfInterest *poi = [[[PlaceOfInterest alloc] init] autorelease];
	poi.view = view;
	poi.poi_location = location;
    poi.fshow = fshow ;
	return poi;
}

@end

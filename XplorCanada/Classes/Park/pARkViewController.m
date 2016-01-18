#import "pARkViewController.h"
#import <AddressBook/AddressBook.h>
#import "GlobalVariable.h"

#define toRad(X) (X*M_PI/180.0)
#define toDeg(X) (X*180.0/M_PI)


@implementation pARkViewController
@synthesize detailView, locationManager,compassView,currentHeading, compassImageView, btnCall, btnDirection, btnShare, btnShowMenu, slider, sliderDistance, btnBack, label_bizName, label_placeName, txt_description, imgBizType, imgCloseDetail ;

- (IBAction)onCall:(id)sender
{
    NSString* callStr = @"tel://" ;
    
    if ( [strPhoneNum length] > 0 )
    {
        NSString* temp = @"" ;
        
        for ( int i = 0 ; i < strPhoneNum.length ; i++ )
        {
            int n = [[strPhoneNum substringWithRange:NSMakeRange(i, 1)] intValue] ;
            if ( n >= 0 && n < 10 )
            {
                temp = [temp stringByAppendingString:[strPhoneNum substringWithRange:NSMakeRange(i, 1)]] ;
            }
            else if ( [temp length] > 1 )
            {
                NSString* temp1 = [strPhoneNum substringWithRange:NSMakeRange(i, 1)] ;
                if ([temp1 isEqualToString:@"0"])
                    temp = [temp stringByAppendingString:@"0"] ;
            }
        }
        
        callStr = [callStr stringByAppendingString:temp] ;
    }
    callStr = [callStr stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callStr]];
}

- (IBAction)onDirection:(id)sender
{
    float sel_lat = [[[table_infos objectAtIndex:k] valueForKey:@"lat"] floatValue] ;
    float sel_lng = [[[table_infos objectAtIndex:k] valueForKey:@"lng"] floatValue] ;
    
    [GlobalVariable sharedInstance].lat2 = sel_lat ;
    [GlobalVariable sharedInstance].lng2 = sel_lng ;

    [GlobalVariable sharedInstance].lat1 = locationManager.location.coordinate.latitude ;
    [GlobalVariable sharedInstance].lng1 = locationManager.location.coordinate.longitude ;
    
    [self performSegueWithIdentifier:@"toDistance" sender:self] ;    
}

- (IBAction)onShare:(id)sender
{
    NSString *temp = label_bizName.text ;
    temp = [temp stringByAppendingString:@"\n"] ;
    temp = [temp stringByAppendingString:label_placeName.text] ;
    temp = [temp stringByAppendingString:@"\n"] ;
    temp = [temp stringByAppendingString:txt_description.text] ;
    temp = [temp stringByAppendingString:@"\n"] ;
    
    NSString *msg = NSLocalizedString(temp, nil);
    NSURL* url = [[NSURL alloc] initWithString:@"http://ixplorecanada.canadaworldapps.com"]  ;
    
    NHCalendarEvent *calendarEvent = [self createCalendarEvent];
    NHCalendarActivity *calendarActivity = [[NHCalendarActivity alloc] init] ;
    calendarActivity.delegate = self;
    
    NSArray *activities = @[calendarActivity];
    
    self.activity = [[UIActivityViewController alloc] initWithActivityItems:@[msg, url, calendarEvent]
                                                      applicationActivities:activities] ;
    
    self.activity.excludedActivityTypes = @[
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypePrint,
                                            UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAssignToContact
                                            ];
    
    [self presentViewController:self.activity
                       animated:YES
                     completion:NULL];
    
}

-(IBAction)onBtnBack:(id)sender
{
    ARView *arView = (ARView *)self.view;
    for (UIView* subview in [arView subviews]) {
        [subview removeFromSuperview];
    }
    
    placesOfInterest = nil ;
    [placesOfInterest release] ;
    [arView removeFromSuperview];
    
    [self.navigationController popToRootViewControllerAnimated:NO] ;
}

-(NHCalendarEvent *)createCalendarEvent
{
    NHCalendarEvent *calendarEvent = [[NHCalendarEvent alloc] init] ;
    
    calendarEvent.title = @"Long-expected Party";
    calendarEvent.location = @"The Shire";
    calendarEvent.notes = @"Bilbo's eleventy-first birthday.";
    calendarEvent.startDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    calendarEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:calendarEvent.startDate];
    calendarEvent.allDay = NO;
    calendarEvent.URL = [NSURL URLWithString:@"http://github.com/otaviocc/NHCalendarActivity"];
    
    // Add alarm
    NSArray *alarms = @[
                        [EKAlarm alarmWithRelativeOffset:- 60.0f * 60.0f * 24],  // 1 day before
                        [EKAlarm alarmWithRelativeOffset:- 60.0f * 15.0f]        // 15 minutes before
                        ];
    calendarEvent.alarms = alarms;
    
    return calendarEvent;
}

#pragma mark - NHCalendarActivityDelegate

-(void)calendarActivityDidFinish:(NHCalendarEvent *)event
{
    NSLog(@"Event created from %@ to %@", event.startDate, event.endDate);
}

-(void)calendarActivityDidFail:(NHCalendarEvent *)event
                     withError:(NSError *)error
{
    NSLog(@"Ops!");
}

- (void)updateHeadingDisplays {
    [UIView     animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGAffineTransform headingRotation;
                             headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(currentHeading));
                             
                             compassImageView.transform = headingRotation ;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)LoadPositions
{
    ARView *arView = (ARView *)self.view;
    for (int i = 0; i < [GlobalVariable sharedInstance].resPositions.count; i++) {
        [self addNewPosition:[[GlobalVariable sharedInstance].resPositions objectAtIndex:i]] ;
    }
    
    [self addPointsToRadar] ;
    [arView setPlacesOfInterest:placesOfInterest];
}

- (void)addNewPosition:(NSDictionary*)_posInfo
{
    UIView*infoView = [self addNewInfoView:_posInfo] ;
    
    float lat = [[_posInfo valueForKey:@"lat"] floatValue] ;
    float lng = [[_posInfo valueForKey:@"lng"] floatValue] ;
    
    CLLocation* points = [[CLLocation alloc] initWithLatitude:lat longitude:lng] ;
    ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:points locationTitle:@"a"] ;
    [coordinate calibrateUsingOrigin:locationManager.location];
    
    PlaceOfInterest *poi = nil ;
    
    if ( coordinate.radialDistance > _range * 1000 )
    {
        poi = [PlaceOfInterest placeOfInterestWithView:infoView at:[[CLLocation alloc] initWithLatitude:lat longitude:lng] show:0] ;
    }
    else
    {
        poi = [PlaceOfInterest placeOfInterestWithView:infoView at:[[CLLocation alloc] initWithLatitude:lat longitude:lng] show:1] ;
    }
    
    if ( placesOfInterest != nil )
    {
        NSMutableArray* temp = [[NSMutableArray alloc] initWithArray:placesOfInterest] ;
        [temp addObject:poi] ;
        placesOfInterest = temp ;
    }
    
    //[placesOfInterest insertObject:poi atIndex:[placesOfInterest count]];
    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelWithGesture:)] ;
    
    [touchOnView setNumberOfTapsRequired:1];
    [touchOnView setNumberOfTouchesRequired:1];
    
    [infoView setTag:k2] ;
    k2 = k2 + 1 ;
    [table_infos addObject:_posInfo] ;
    
    [infoView addGestureRecognizer:touchOnView];
    
    //[arView setPlacesOfInterest:placesOfInterest];
    //[self addPointsToRadar] ;
}

- (UIView*)addNewInfoView:(NSDictionary*)infoDetail
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 120, 70)] ;
    label.adjustsFontSizeToFitWidth = NO;
    label.opaque = NO;
    
    label.backgroundColor = [UIColor colorWithRed:(7/255.0) green:(48/255.0) blue:(110/255.0) alpha:1];
    label.textColor = [UIColor whiteColor];
    
    label.text = [infoDetail valueForKey:@"name"] ;
    
    [label setFont:[UIFont systemFontOfSize:16]] ;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    [label setTextAlignment:NSTextAlignmentCenter] ;
    CGSize aSize = label.bounds.size;
    CGSize tmpSize = CGRectInfinite.size;
    tmpSize.width = aSize.width;
    tmpSize = [label.text sizeWithFont:label.font constrainedToSize:tmpSize];
    label.frame = CGRectMake(label.frame.origin.x, 55, aSize.width, tmpSize.height);
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] ;
    
    if ( [[infoDetail valueForKey:@"icon"] length] > 1 )
    {
        NSString* strUri = [infoDetail valueForKey:@"icon"] ;
        NSURL *imageURL = [NSURL URLWithString:strUri];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                [imgView setImage:image] ;
            });
        });
    }
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(600, 600, 100, imgView.frame.size.height + label.frame.size.height)] ;
    [infoView setBackgroundColor:[UIColor clearColor]] ;
    [infoView addSubview:label] ;
    [infoView addSubview:imgView] ;
    
    imgView.center = CGPointMake(infoView.bounds.size.width/2, 40) ;
    label.center = CGPointMake(infoView.bounds.size.width/2, infoView.bounds.size.height/2+45) ;
    
    if ( label.frame.origin.y < imgView.frame.size.height )
    {
        label.frame = CGRectMake(label.frame.origin.x, imgView.frame.size.width, label.frame.size.width, label.frame.size.height) ;
    }
    
    return infoView ;
}

- (void)addPointsToRadar
{
    for (UIImageView *subview in [compassView subviews]) {
        if (subview.tag != 888) {
            [subview removeFromSuperview];
        }
    }
    
    for ( int i = 0 ; i < placesOfInterest.count ; i++ )
    {
        CLLocation * point = [[placesOfInterest objectAtIndex:i] poi_location] ;
        ARGeoCoordinate *poi = [ARGeoCoordinate coordinateWithLocation:point locationTitle:@"a"];
        [poi calibrateUsingOrigin:locationManager.location];

        if ( [[placesOfInterest objectAtIndex:i] fshow] == 1 )
        {
            float scale = _range *1000 / RADIUS;
            float x, y;
            //case1: azimiut is in the 1 quadrant of the radar
            float f = cosf((M_PI / 2) - poi.azimuth) ;
            f = cosf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale) ;
            f = RADIUS + cosf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale) ;
            
            float f2 = sinf((M_PI / 2) - poi.azimuth) ;
            f2 = sinf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale) ;
            f2 = RADIUS - sinf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale) ;
            
            if (poi.azimuth >= 0 && poi.azimuth < M_PI / 2) {
                x = RADIUS + cosf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
                y = RADIUS - sinf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
            } else if (poi.azimuth > M_PI / 2 && poi.azimuth < M_PI) {
                //case2: azimiut is in the 2 quadrant of the radar
                x = RADIUS + cosf(poi.azimuth - (M_PI / 2)) * (poi.radialDistance / scale);
                y = RADIUS + sinf(poi.azimuth - (M_PI / 2)) * (poi.radialDistance / scale);
            } else if (poi.azimuth > M_PI && poi.azimuth < (3 * M_PI / 2)) {
                //case3: azimiut is in the 3 quadrant of the radar
                x = RADIUS - cosf((3 * M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
                y = RADIUS + sinf((3 * M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
            } else if(poi.azimuth > (3 * M_PI / 2) && poi.azimuth < (2 * M_PI)) {
                //case4: azimiut is in the 4 quadrant of the radar
                x = RADIUS - cosf(poi.azimuth - (3 * M_PI / 2)) * (poi.radialDistance / scale);
                y = RADIUS - sinf(poi.azimuth - (3 * M_PI / 2)) * (poi.radialDistance / scale);
            } else if (poi.azimuth == 0) {
                x = RADIUS;
                y = RADIUS - poi.radialDistance / scale;
            } else if(poi.azimuth == M_PI/2) {
                x = RADIUS + poi.radialDistance / scale;
                y = RADIUS;
            } else if(poi.azimuth == (3 * M_PI / 2)) {
                x = RADIUS;
                y = RADIUS + poi.radialDistance / scale;
            } else if (poi.azimuth == (3 * M_PI / 2)) {
                x = RADIUS - poi.radialDistance / scale;
                y = RADIUS;
            } else {
                //If none of the above match we use the scenario where azimuth is 0
                x = RADIUS;
                y = RADIUS - poi.radialDistance / scale;
            }
            
            UIImage* img = [UIImage imageNamed:@"point.png"] ;
            UIImageView* imgView = [[UIImageView alloc] initWithImage:img] ;
            [imgView setFrame:CGRectMake(x, y, 5, 5)] ;
            
            if ( pow(x-50,2) + pow(y-50,2) < pow(RADIUS - 5, 2) )
                [compassView addSubview:imgView] ;
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    k2 = 0 ;
    table_infos = [[NSMutableArray alloc] init] ;
    locationManager = [[CLLocationManager alloc] init] ;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
	locationManager.delegate = self ;
	
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    placesOfInterest = [NSMutableArray arrayWithCapacity:[GlobalVariable sharedInstance].resPositions.count];
    currentHeading = 0.0;
    
    [btnBack setContentEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)] ;
    [compassView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 115, 30, 100, 100)] ;
    [detailView setAlpha:0.0] ;
    
    _range = 1 ;
    
    [slider setMinimumValue:0.0] ;
    [slider setMaximumValue:20.0] ;
    [slider setValue:1.0] ;

    [self LoadPositions] ;
    
    [GlobalVariable sharedInstance].table_google = [[NSMutableArray alloc] init] ;
    someQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(someQueue, ^{
        [self performSelectorOnMainThread:@selector(getDetailedInformation:) withObject:[GlobalVariable sharedInstance].table_references waitUntilDone:YES] ;
    });
}

- (void)getDetailedInformation:(NSMutableArray*)dataArr
{
    for ( int i = 0 ; i < dataArr.count ; i++ )
    {
        NSString* reference = [[[GlobalVariable sharedInstance].table_references objectAtIndex:i] valueForKey:@"reference"] ;
        NSString* url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/xml?reference=%@&sensor=false&key=%@", reference, kGOOGLE_API_KEY] ;
        
        __block ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]]  ;
        request.requestMethod = @"POST" ;
        [request setCompletionBlock:^{
            
            if ( request != nil )
            {
                int statusCode = [request responseStatusCode] ;
                if (statusCode == 200) {
                    NSString * responseString = [request responseString] ;
                    responseString = [responseString stringByReplacingOccurrencesOfString:@"&" withString:@" "] ;
                    NSMutableArray  *dataArr =  [self parseDataWithDict:[responseString dataUsingEncoding:NSUTF8StringEncoding] withString:@"result"] ;
                        
                    for ( int i = 0 ; i < dataArr.count ; i++ )
                    {
                        NSMutableDictionary* temp = [[NSMutableDictionary alloc] initWithCapacity:8] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"name"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"name"] forKey:@"name"] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"vicinity"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"vicinity"] forKey:@"address"] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"icon"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"icon"] forKey:@"icon"] ;
                        
                        [temp setObject:@"-1" forKey:@"kind"] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"lat"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"lat"] forKey:@"lat"] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"lng"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"lng"] forKey:@"lng"] ;
                        
                        if ( [[[dataArr objectAtIndex:i] valueForKey:@"formatted_phone_number"] length] > 0 )
                            [temp setObject:[[dataArr objectAtIndex:i] valueForKey:@"formatted_phone_number"] forKey:@"call_num"] ;
                            
                        NSString* _description = [NSString stringWithFormat:@" Address %@\n Phone Number %@\n International Phone Number %@\n Website %@",
                                                      [[dataArr objectAtIndex:i] valueForKey:@"formatted_address"],
                                                      [[dataArr objectAtIndex:i] valueForKey:@"formatted_phone_number"],
                                                      [[dataArr objectAtIndex:i] valueForKey:@"international_phone_number"],
                                                      [[dataArr objectAtIndex:i] valueForKey:@"url"]];
                            
                        [temp setObject:_description forKey:@"description"] ;
                        ARView *arView = (ARView *)self.view;
                        [self addNewPosition:temp] ;
                            
                        [arView setPlacesOfInterest:placesOfInterest];
                        [self addPointsToRadar] ;
                        
                        [[GlobalVariable sharedInstance].table_google addObject:temp] ;
                    }
                    
                    [self addPointsToRadar] ;
                }
            }
        }];
        
        [request setFailedBlock:^{
            //NSError *error = [request error];
            //NSLog(@"%@", error.description) ;
        }];
        
        [request startAsynchronous] ;
    }
}

- (NSMutableArray *)parseDataWithDict:(NSData *)_data withString:(NSString*)parseString
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:_data] ;
    NSMutableDictionary *fectchDataDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    XMLParser *parser = [[XMLParser alloc] initXMLParser:parseString] ;
    [xmlParser setDelegate:parser];
    [xmlParser parse];
    
    [fectchDataDic setObject:parser.parsedXML forKey:@"root"];
    NSMutableArray *dataArr=[fectchDataDic objectForKey:@"root"];
    
    return dataArr;
}

- (IBAction)onSliderChange:(id)sender
{
    [sliderDistance setText:[NSString stringWithFormat:@"%d km", (int)[slider value]]] ;
    _range = [slider value] ;
    
    for ( int i = 0 ; i < placesOfInterest.count ; i++ )
    {
        CLLocation * point = [[placesOfInterest objectAtIndex:i] poi_location] ;
        
        ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:point locationTitle:@"a"];
        [coordinate calibrateUsingOrigin:locationManager.location];
        
        NSLog(@"%f, %f, - %f", point.coordinate.latitude, point.coordinate.longitude, coordinate.radialDistance) ;
        
        if ( coordinate.radialDistance > _range * 1000 )
        {
            [[placesOfInterest objectAtIndex:i] setFshow:0] ;
        }
        else
        {
            [[placesOfInterest objectAtIndex:i] setFshow:1] ;
        }
    }
    
    [self addPointsToRadar] ;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    cur_lat = [[NSString stringWithFormat:@"%f",location.coordinate.latitude] floatValue] ;
    cur_lng = [[NSString stringWithFormat:@"%f",location.coordinate.longitude] floatValue] ;
    
    [self updateHeadingDisplays];
}

- (void)startLocationHeadingEvents {
    if (!self.locationManager) {
        CLLocationManager* theManager = [[CLLocationManager alloc] init] ;
        
        // Retain the object in a property.
        self.locationManager = theManager;
        locationManager.delegate = self;
    }
    
    // Start location services to get the true heading.
    locationManager.distanceFilter = 1;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = 5;
        [locationManager startUpdatingHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    [self updateHeadingDisplays] ;
}

- (void)didTapLabelWithGesture:(UITapGestureRecognizer *)tapGesture
{
    int nIndex = (int)[tapGesture.view tag] ;
    
    //[detailView setHidden:NO] ;
    
    [UIView beginAnimations:nil context:NULL] ;
    [UIView setAnimationDuration:0.75] ;
    [detailView setAlpha:1.0] ;
    [self.view bringSubviewToFront:detailView] ;
    [UIView commitAnimations];
    
    if ( [[[table_infos objectAtIndex:nIndex] valueForKey:@"name"] length] > 1 )
        [label_bizName setText:[[table_infos objectAtIndex:nIndex] valueForKey:@"name"]] ;
    
    if ( [[[table_infos objectAtIndex:nIndex] valueForKey:@"address"] length] > 1 )
        [label_placeName setText:[[table_infos objectAtIndex:nIndex] valueForKey:@"address"]] ;
    
    k = nIndex ;
    
    if ([[[table_infos objectAtIndex:nIndex] valueForKey:@"call_num"] length] > 0 )
    {
        [btnCall setEnabled:YES] ;
        strPhoneNum = [[table_infos objectAtIndex:nIndex] valueForKey:@"call_num"] ;
    }
    else
    {
        [btnCall setEnabled:NO] ;
        strPhoneNum = @"" ;
    }
    
    if ([[[table_infos objectAtIndex:nIndex] valueForKey:@"description"] length] > 0)
        [txt_description setText:[[table_infos objectAtIndex:nIndex] valueForKey:@"description"]] ;
    
    if ( IDIOM == IPAD )
        [txt_description setFont:[UIFont systemFontOfSize:20]] ;
    
    NSURL *imageURL = nil ;
    
    if ( [[[table_infos objectAtIndex:nIndex] valueForKey:@"icon"] length] > 0 )
        imageURL = [NSURL URLWithString:[[table_infos objectAtIndex:nIndex] valueForKey:@"icon"]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            [imgBizType setImage:image] ;
        });
    });
}

- (IBAction)onCloseDetail:(id)sender
{
    [UIView beginAnimations:nil context:NULL] ;
    [UIView setAnimationDuration:0.75] ;
    [detailView setAlpha:0.0] ;
    [self.view bringSubviewToFront:detailView] ;
    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	ARView *arView = (ARView *)self.view;
    [arView start];
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    [self startLocationHeadingEvents];
    [self updateHeadingDisplays];
    
    if ( btnShowMenu == nil )
    {
        btnShowMenu = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, [UIScreen mainScreen].bounds.size.height - 30, 71, 30)] ;
        [btnShowMenu setImage:[UIImage imageNamed:@"fold_view_up.png"] forState:UIControlStateNormal] ;
        [self.view addSubview:btnShowMenu];
        [btnShowMenu addTarget:self action:@selector(OpenFolder) forControlEvents:UIControlEventTouchUpInside];
        
        [slider setAlpha:0.0f] ;
        [sliderDistance setAlpha:0.0f] ;
        
        [slider setFrame:CGRectMake(slider.frame.origin.x, [UIScreen mainScreen].bounds.size.height - slider.frame.size.height, slider.frame.size.width, slider.frame.size.height)] ;
        [sliderDistance setFrame:CGRectMake(sliderDistance.frame.origin.x, [UIScreen mainScreen].bounds.size.height - sliderDistance.frame.size.height, sliderDistance.frame.size.width, sliderDistance.frame.size.height)] ;
        
        btnCall.layer.borderWidth = 1;
        btnCall.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        btnDirection.layer.borderWidth = 1;
        btnDirection.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        btnShare.layer.borderWidth = 1;
        btnShare.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }    
}

- (void)OpenFolder
{
    if ( msgVC != nil )
    {
        [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void) {
                             
                             [slider setAlpha:0.0f] ;
                             [sliderDistance setAlpha:0.0f] ;
                             
                             [msgVC hideMsg] ;
                             msgVC = nil ;
                             [btnShowMenu setFrame:CGRectMake(btnShowMenu.frame.origin.x, [UIScreen mainScreen].bounds.size.height - btnShowMenu.frame.size.height, btnShowMenu.frame.size.width, btnShowMenu.frame.size.height)] ;
                             
                         }
                         completion:^(BOOL finished){
                             [btnShowMenu setImage:[UIImage imageNamed:@"fold_view_up.png"] forState:UIControlStateNormal] ;
                             
                             
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void) {
                             
                             msgVC = [[ARMenuViewController alloc] initWithTitle:@"Sliding Message View" message:@"With a 5 second delay"];
                             [self.view addSubview:msgVC.view];
                             [msgVC showMsgWithDelay:5];
                             [btnShowMenu setFrame:CGRectMake(btnShowMenu.frame.origin.x, [UIScreen mainScreen].bounds.size.height - 135 - btnShowMenu.frame.size.height, btnShowMenu.frame.size.width, btnShowMenu.frame.size.height)] ;
                             
                             [slider setAlpha:1.0f] ;
                             [sliderDistance setAlpha:1.0f] ;
                         }
                         completion:^(BOOL finished){
                             
                             [btnShowMenu setImage:[UIImage imageNamed:@"fold_view_down.png"] forState:UIControlStateNormal] ;

                         }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.locationManager) {
        [locationManager stopUpdatingHeading];
        [locationManager stopUpdatingLocation];
    }
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [GlobalVariable sharedInstance].lat1 = locationManager.location.coordinate.latitude ;
    [GlobalVariable sharedInstance].lng1 = locationManager.location.coordinate.longitude ;
    
    ARView *arView = (ARView *)self.view;
    /*
    for (UIView* subview in [arView subviews]) {
        [subview removeFromSuperview];
    }
    */
    [arView stop];
    //placesOfInterest = nil ;
    //[placesOfInterest release] ;
    //[arView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end

//
//  PlacesLoader.m
//  Around Me
//
//  Created by jdistler on 06.02.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import "PlacesLoader.h"

#import <CoreLocation/CoreLocation.h>
#import <Foundation/NSJSONSerialization.h>
#import "GlobalVariable.h"
#import "Place.h"

NSString * apiURL = @"https://maps.googleapis.com/maps/api/place/";
NSString * const apiKey = @"AIzaSyDFoGdRdyVe_dcPXHwxgxI9MfOUJWOd3C8";

@interface PlacesLoader ()

@property (nonatomic, strong) SuccessHandler successHandler;
@property (nonatomic, strong) ErrorHandler errorHandler;
@property (nonatomic, strong) NSMutableData *responseData;

@end


@implementation PlacesLoader

+ (PlacesLoader *)sharedInstance {
	static PlacesLoader *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[PlacesLoader alloc] init];
	});
	
	return instance;
}

- (void)loadPOIsForLocation:(CLLocation *)location radius:(int)radius successHanlder:(SuccessHandler)handler errorHandler:(ErrorHandler)errorHandler {
	_responseData = nil;
	_successHandler = handler;
	_errorHandler = errorHandler;
	
    apiURL = @"http://ixplorecanada.canadaworldapps.com/locations.php?" ;
    apiURL = [apiURL stringByAppendingString:@"&kind="] ;
    apiURL = [apiURL stringByAppendingString:[GlobalVariable sharedInstance].position_kind];
    
	NSMutableString *uri = [NSMutableString stringWithString:apiURL];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"POST"];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSLog(@"Starting connection: %@ for request: %@", connection, request);
}

- (void)loadDetailInformation:(Place *)location successHanlder:(SuccessHandler)handler errorHandler:(ErrorHandler)errorHandler {
	_responseData = nil;
	_successHandler = handler;
	_errorHandler = errorHandler;
	
    apiURL = @"http://ixplorecanada.canadaworldapps.com/getBusinessInfo.php?" ;
    apiURL = [apiURL stringByAppendingString:@"&name="] ;
    apiURL = [apiURL stringByAppendingString:[location address]];
    NSMutableString *uri = [NSMutableString stringWithString:apiURL];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"GET"];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

	NSLog(@"Starting connection: %@ for request: %@", connection, request);
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if(!_responseData) {
		_responseData = [NSMutableData dataWithData:data];
	} else {
		[_responseData appendData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    id object = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:nil];
    if(_successHandler) {
        _successHandler(object);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if(_errorHandler) {
		_errorHandler(error);
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end

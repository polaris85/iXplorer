//
//  Place.m
//  Around Me
//
//  Created by jdistler on 11.02.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import "Place.h"

@implementation Place

- (id)initWithLocation:(CLLocation *)location reference:(NSString *)reference name:(NSString *)name address:(NSString *)address{
	if((self = [super init])) {
		_location = location;
		_placeName = [name copy];
		_address = [address copy];
	}
	
	return self;
}

- (NSString *)infoText {
	return [NSString stringWithFormat:@"%@", _address];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@", _placeName];
}

@end

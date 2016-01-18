//
//  GlobalVariable.m
//  TCM
//
//  Created by Adam on 12/27/13.
//  Copyright (c) 2013 com.appcoda. All rights reserved.
//

#import "GlobalVariable.h"

@implementation GlobalVariable

+(GlobalVariable *)sharedInstance
{
    static GlobalVariable *myGlobal = nil;
    
    if (myGlobal == nil) {
        myGlobal = [[[self class] alloc] init];
    }
    return myGlobal;
}

@end

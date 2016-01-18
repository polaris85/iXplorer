//
//  ARMenuViewController.h
//  iXplorCanada
//
//  Created by Kang on 6/9/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalVariable.h"

@interface ARMenuViewController : UIViewController
{
    UIButton* btnArView ;
    UIButton* btnListView ;
    UIButton* btnMapView ;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)msg;
- (void)showMsgWithDelay:(int)delay;
- (void)hideMsg;
@end
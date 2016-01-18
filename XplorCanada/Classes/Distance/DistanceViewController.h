//
//  DistanceViewController.h
//  iXplorCanada
//
//  Created by Adam on 3/14/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistanceViewController : UIViewController
@property (assign, nonatomic) IBOutlet UIWebView* webView ;
@property (assign, nonatomic) IBOutlet UIButton* btnBack ;
-(IBAction)onReturn:(id)sender;
@end

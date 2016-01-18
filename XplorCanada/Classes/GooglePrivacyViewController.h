//
//  GooglePrivacyViewController.h
//  iXplorCanada
//
//  Created by Kang on 6/13/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GooglePrivacyViewController : UIViewController

@property (assign, nonatomic) IBOutlet UIWebView* webView ;
@property (nonatomic, retain) IBOutlet UILabel* label_Title ;

-(IBAction)onReturn:(id)sender;

@end

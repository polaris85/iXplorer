//
//  SettingViewController.h
//  xplor
//
//  Created by Adam on 3/3/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate>

{
    UITableView* mtable ;
    NSArray *tableData1;
    NSArray *tableData2;
}

@property (nonatomic, strong) IBOutlet UIButton *   btnBack ;

-(IBAction)onReturn:(id)sender;
@end

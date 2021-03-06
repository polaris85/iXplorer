//
//  LandingViewController.h
//  iXplorCanada
//
//  Created by Kang on 6/8/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Countries.h"
#import "GlobalVariable.h"

@interface LandingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* mtable ;
@property (strong) Countries *countries;
@property (nonatomic, strong) NSString *currentItemString;
@property (nonatomic) int currentItem;
@property (nonatomic, strong) NSIndexPath* checkedIndexPath;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *filteredCountries;
@property (assign) BOOL isFiltered;


@end

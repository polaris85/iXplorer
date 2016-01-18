//
//  LandingViewController.m
//  iXplorCanada
//
//  Created by Kang on 6/8/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "LandingViewController.h"
#import "../ViewController.h"

@interface LandingViewController ()

@end

@implementation LandingViewController

@synthesize mtable ;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _countries = [Countries sharedInstance];
    [_countries loadCountries];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,70,320,44)];
    [mtable setTableHeaderView:self.searchBar];
    self.searchBar.delegate = (id)self;
    self.searchBar.showsCancelButton = YES;
    self.isFiltered = NO;
    
    self.mtable.contentInset = UIEdgeInsetsMake(0, 0, 140, 0);
    [self.mtable setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]] ;
    self.currentItemString = [[NSUserDefaults standardUserDefaults] objectForKey:@"country"] ;
    [mtable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = NO;
    }
    else
    {
        self.isFiltered = YES;
        self.filteredCountries = [[NSMutableArray alloc] init];
        
        for (NSString* countryName in _countries.countries)
        {
            NSRange nameRange = [countryName rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
            {
                [self.filteredCountries addObject:countryName];
            }
        }
    }
    
    [mtable reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.text = @"";
    self.isFiltered = NO;
    [mtable reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rowCount = 0 ;
    
    if(self.isFiltered)
        rowCount = (int)self.filteredCountries.count;
    else
        rowCount = (int)[_countries.countries count];
    
    return rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"    Select your Country";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IDIOM == IPAD )
        return 60 ;
    else
        return 50 ;
}

- (IBAction)onCurrentCountry:(id)sender
{
    NSLocale *usLocale = [NSLocale currentLocale] ;
    NSString *countryCode = [usLocale objectForKey:NSLocaleCountryCode] ;
    NSString *countryName = [usLocale displayNameForKey:NSLocaleCountryCode value:countryCode] ;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults] ;
    [prefs setObject:countryName forKey:@"country"] ;
    [prefs synchronize] ;
    
    [self.navigationController popViewControllerAnimated:YES] ;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    if (cell == nil) {
        [mtable setSeparatorInset:UIEdgeInsetsMake(-10, 0, -10, 0)] ;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        [cell setFrame:CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y, (cell.frame.size.width - 20), cell.frame.size.height)] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ( IDIOM == IPAD )
            cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
        else
            cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
        
        [cell setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]] ;
            
        NSString *countryName  = (self.isFiltered) ? [self.filteredCountries objectAtIndex:indexPath.row] :
        [_countries.countries objectAtIndex:indexPath.row];
        
        countryName = [countryName stringByReplacingOccurrencesOfString:@"\r" withString:@""] ;
        if ([countryName isEqualToString:self.currentItemString]) {
            self.checkedIndexPath = indexPath;
        }
        
        cell.textLabel.text = countryName;
        countryName = [countryName stringByReplacingOccurrencesOfString:@" " withString:@""] ;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        NSString *flagFileName = [_countries getFlagFileNameWithName:countryName];
        cell.imageView.image = [UIImage imageNamed:flagFileName];
        [cell.imageView setFrame:CGRectMake(0, 0, cell.imageView.frame.size.width, cell.imageView.frame.size.height)] ;
        
        if (!(self.isFiltered)) {
            if([self.checkedIndexPath isEqual:indexPath]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.checkedIndexPath) {
        UITableViewCell* uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    self.currentItemString = (self.isFiltered) ? [self.filteredCountries objectAtIndex:indexPath.row]:
    [_countries.countries objectAtIndex:indexPath.row];
    
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults] ;
    
    [prefs setObject:[[self.currentItemString stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"%20"] forKey:@"country"] ;
    [prefs synchronize];
    
    [self.navigationController popViewControllerAnimated:YES] ;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

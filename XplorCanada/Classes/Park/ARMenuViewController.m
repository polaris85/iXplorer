//
//  ARMenuViewController.m
//  iXplorCanada
//
//  Created by Kang on 6/9/14.
//  Copyright (c) 2014 com.xplor. All rights reserved.
//

#import "ARMenuViewController.h"
#import "../Location/LocationMapViewController.h"
#import "pARkViewController.h"

@interface ARMenuViewController ()

@end

@implementation ARMenuViewController

#pragma mark -
#pragma mark Private Methods

- (void)hideMsg;
{
    // Slide the view down off screen
    CGRect frame = self.view.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    self.view.frame = frame;
    
    // To autorelease the Msg, define stop selector
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context
{
    
}

- (id)initWithTitle:(NSString *)title message:(NSString *)msg
{
    if (self = [super init])
    {
        if ( IDIOM == IPAD )
            self.view = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 320, [UIScreen mainScreen].bounds.size.height, 320, 80)] ;
        else
            self.view = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 80)] ;
        [self.view setBackgroundColor:[UIColor colorWithRed:192.0/255.0 green:12.0/255.0 blue:10.0/255.0 alpha:1.0]];
        
        btnArView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 3, self.view.frame.size.height)] ;
        [btnArView setBackgroundImage:[UIImage imageNamed:@"btnARView.png"] forState:UIControlStateNormal] ;
        [btnArView addTarget:self action:@selector(onArView:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:btnArView];
        
        btnListView = [[UIButton alloc] initWithFrame:CGRectMake( self.view.frame.size.width / 3, 0, self.view.frame.size.width / 3, self.view.frame.size.height)] ;
        [btnListView setBackgroundImage:[UIImage imageNamed:@"btnListView.png"] forState:UIControlStateNormal] ;
        [btnListView addTarget:self action:@selector(onListView:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:btnListView];
        
        btnMapView = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 3 * 2, 0, self.view.frame.size.width / 3, self.view.frame.size.height)] ;
        [btnMapView setBackgroundImage:[UIImage imageNamed:@"btnMapView.png"] forState:UIControlStateNormal] ;
        [btnMapView addTarget:self action:@selector(onMapView:) forControlEvents:UIControlEventTouchUpInside] ;
        [self.view addSubview:btnMapView];
    }
    
    return self;
}

- (void)onArView:(id)sender
{
    
}

- (void)onListView:(id)sender
{
    UIViewController* superViewController = nil ;
    
    for (UIView* next = [self.view superview] ; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder] ;
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            superViewController = (pARkViewController*)nextResponder ;
            break ;
        }
    }
    
    [superViewController performSegueWithIdentifier:@"toPlaceList" sender:superViewController] ;
}

- (void)onMapView:(id)sender
{
    UIViewController* superViewController = nil ;
    
    for (UIView* next = [self.view superview] ; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder] ;
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            superViewController = (pARkViewController*)nextResponder ;
            break ;
        }
    }
        
    [superViewController performSegueWithIdentifier:@"toLocationMap" sender:superViewController] ;
    
}

- (void)showMsgWithDelay:(int)delay
{
    //  UIView *view = self.view;
    CGRect frame = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    
    // Slide up based on y axis
    // A better solution over a hard-coded value would be to
    // determine the size of the title and msg labels and
    // set this value accordingly
    
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - 135 ;
    self.view.frame = frame;
    
    [UIView commitAnimations];
    
    // Hide the view after the requested delay
    //[self performSelector:@selector(hideMsg) withObject:nil afterDelay:delay];
    
}

@end

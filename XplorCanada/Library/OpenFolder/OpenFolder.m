//
//  OpenFolder.m
//  MyFolder
//
//  Created by yangjunying on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OpenFolder.h"

#import <QuartzCore/QuartzCore.h>
#import "UIView+Screenshot.h"
#import "UIScreen+Scale.h"

static OpenFolder *sharedOpenFolder = nil;

@interface OpenFolder ()

- (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                         delegate:(id)delegate;

- (void)MakeSubviewAlpha:(UIView *)view notWithView:(UIView *)notWithView alpha:(CGFloat)alpha;

- (OpenFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen arrowDirection:(ArrowDirection)arrowDirection position:(CGPoint)position;

- (void)SetBackImage:(UIView*)theView aRect:(CGRect)aRect andScreen:(UIImage *)screen;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)CleanUp;
- (void)FolderWillClose;

@end


@implementation OpenFolder

@synthesize contentController = _contentController;
@synthesize contentView = _contentView;
@synthesize delegate = _delegate;
@synthesize coverView = _coverView;
@synthesize containerView = _containerView;
@synthesize folderPosition = _folderPosition;

@synthesize partOneView = _partOneView;
@synthesize partTwoView = _partTwoView;

@synthesize userInfo = _userInfo;

@synthesize splitOrientation = _splitOrientation;

- (id)init
{
    self = [super init];
    if(self)
    {
        IsOpen = NO;
        IsOpenAnimated = YES;
        _splitOrientation = SplitOrientationVertical;
    }
    
    return self;
}

- (void)dealloc
{
    [self CleanUp];
    [super dealloc];
}

+ (OpenFolder *)ShareOpenFolder
{
    if(sharedOpenFolder == nil)
    {
        sharedOpenFolder = [[OpenFolder alloc] init];
    }
    
    return sharedOpenFolder;
}

- (void)dealOpenFolder
{
//    NSLog(@"%f,%f",self.folderPosition.x,self.folderPosition.y);
    if(self.coverView == nil)
    {
        self.coverView = [[[CoverView alloc] initWithFrame:self.containerView.bounds] autorelease];
        self.coverView.autoresizingMask = self.containerView.autoresizingMask;
        self.coverView.clipsToBounds = YES;
    }
    self.coverView.position = self.folderPosition;
    self.coverView.contentView = self.contentView;
    self.coverView.frame = self.containerView.bounds;
    
    if(self.coverView.superview)
    {
//        [self.coverView removeFromSuperview];
        [self.coverView setHidden:YES];
    }
    
    if(IsOpen == NO)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderWillOpen:withFrame:userInfo:)])
        {
            [_delegate OpenFolder:self folderWillOpen:self.contentController withFrame:self.contentView.frame userInfo:self.userInfo];
        }
    }
    
    [self MakeSubviewAlpha:self.containerView notWithView:self.coverView alpha:1.0];
    
    UIImage *screenshot = [self.containerView screenshot];
    
    CGRect containerRect = self.containerView.bounds;
    CGFloat width = containerRect.size.width;
    CGFloat height = containerRect.size.height;
    
    CGFloat contentViewWidthOrHeight = 0;
    
    if(_splitOrientation == SplitOrientationVertical)
    {
        contentViewWidthOrHeight = self.contentView.frame.size.height;
    }
    else 
    {
        contentViewWidthOrHeight = self.contentView.frame.size.width;
    }

    if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:contentViewHeightOrWidth:orientation:userInfo:)])
    {
        CGFloat woh = [_delegate OpenFolder:self contentViewHeightOrWidth:self.contentController orientation:_splitOrientation userInfo:self.userInfo];
        if(woh > 0)
        {
            contentViewWidthOrHeight = woh;
        }
    }
    
    if(_splitOrientation == SplitOrientationVertical)
    {
        if(contentViewWidthOrHeight > (height * 0.8))
        {
            contentViewWidthOrHeight = (height * 0.8);
        }
    }
    else 
    {
        if(contentViewWidthOrHeight > (width * 0.8))
        {
            contentViewWidthOrHeight = (width * 0.8);
        }
    }
    
    
    CGRect contentRc = CGRectZero;
    CGFloat p1,p2;
    
    if(_splitOrientation == SplitOrientationVertical)
    {
        p2 = self.folderPosition.y + contentViewWidthOrHeight;
        if(p2 >= height*0.8)
        {
            p2 = height*0.8;
            
            if(p2 < self.folderPosition.y)
            {
                p2 = self.folderPosition.y;
            }
        }
        p1 = p2-contentViewWidthOrHeight;
        
        contentRc = CGRectMake(0, p1, containerRect.size.width, contentViewWidthOrHeight);
    }
    else 
    {
        p2 = self.folderPosition.x + contentViewWidthOrHeight;
        if(p2 >= width*0.8)
        {
            p2 = width*0.8;
            
            if(p2 < self.folderPosition.x)
            {
                p2 = self.folderPosition.x;
            }
        }
        p1 = p2-contentViewWidthOrHeight;
        
        contentRc = CGRectMake(p1, 0, contentViewWidthOrHeight,containerRect.size.height);
    }
    
//    self.coverView.position = self.folderPosition;
    
    self.contentView.frame = contentRc;
    if(self.contentView.superview == nil)
    {
        [self.coverView addSubview:self.contentView];
    }
    
    CGRect upperRect = CGRectZero;
    if(_splitOrientation == SplitOrientationVertical)
    {
        upperRect = CGRectMake(0, 0, width, self.folderPosition.y);
    }
    else 
    {
        upperRect = CGRectMake(0, 0, self.folderPosition.x,height);
    }
    if(self.partOneView == nil)
    {
        self.partOneView = [self buttonForRect:upperRect andScreen:screenshot arrowDirection:_partOneArrowDirection position:self.folderPosition];
        self.partOneView.autoresizingMask = (_splitOrientation == SplitOrientationVertical)?UIViewAutoresizingFlexibleWidth:UIViewAutoresizingFlexibleHeight;
        
        [self.coverView addSubview:self.partOneView];
        self.coverView.partOneView = self.partOneView;
        
        [self.partOneView addTarget:self action:@selector(FolderWillClose) forControlEvents:UIControlEventTouchUpInside];
        
        [self.partOneView layer].masksToBounds = NO;
        self.partOneView.layer.shadowOpacity = 0.65;
        self.partOneView.layer.shadowColor = [UIColor colorWithWhite:0.08 alpha:0.89].CGColor;
        [self.partOneView layer].shadowRadius = 1.0f;
        self.partOneView.layer.shouldRasterize = YES;
    }
    else 
    {
        [self SetBackImage:self.partOneView aRect:upperRect andScreen:screenshot];
        if(self.partOneView.superview == nil)
        {
            [self.coverView addSubview:self.partOneView];
        }
    }
    self.partOneView.fromRect = _fromRect;
    self.partOneView.splitOrientation = self.splitOrientation;
    self.partOneView.arrowType = _partOneArrowDirection;
    if(_splitOrientation == SplitOrientationVertical)
    {
        self.partOneView.layer.shadowOffset = CGSizeMake(0, 6);
    }
    else 
    {
        self.partOneView.layer.shadowOffset = CGSizeMake(6, 0);
    }    
    
    CGRect lowerRect = CGRectZero;
    if(_splitOrientation == SplitOrientationVertical)
    {
        lowerRect = CGRectMake(0, self.folderPosition.y, width, height - self.folderPosition.y);
    }
    else 
    {
        lowerRect = CGRectMake(self.folderPosition.x, 0, width-self.folderPosition.x, height);
    }
    if(self.partTwoView == nil)
    {
        self.partTwoView = [self buttonForRect:lowerRect andScreen:screenshot arrowDirection:_partTwoArrowDirection position:self.folderPosition];
        
        self.partTwoView.autoresizingMask = (_splitOrientation == SplitOrientationVertical)?UIViewAutoresizingFlexibleWidth:UIViewAutoresizingFlexibleHeight;
        
        [self.coverView addSubview:self.partTwoView];
        self.coverView.partTwoView = self.partTwoView;
        
        [self.partTwoView addTarget:self action:@selector(FolderWillClose) forControlEvents:UIControlEventTouchUpInside];
        
        [self.partTwoView layer].masksToBounds = NO;        
        self.partTwoView.layer.shadowOpacity = 0.65;
        self.partTwoView.layer.shadowColor = [UIColor colorWithWhite:0.08 alpha:0.89].CGColor;
        [self.partTwoView layer].shadowRadius = 1.0f;
        self.partTwoView.layer.shouldRasterize = YES;
    }
    else 
    {
        [self SetBackImage:self.partTwoView aRect:lowerRect andScreen:screenshot];
        if(self.partTwoView.superview == nil)
        {
            [self.coverView addSubview:self.partTwoView];
        }
    }
    self.partTwoView.fromRect = _fromRect;
    self.partTwoView.splitOrientation = self.splitOrientation;
    self.partTwoView.arrowType = _partTwoArrowDirection;
    if(_splitOrientation == SplitOrientationVertical)
    {
        self.partTwoView.layer.shadowOffset = CGSizeMake(0, -6);
    }
    else 
    {
        self.partTwoView.layer.shadowOffset = CGSizeMake(-6, 0);
    }
    
    if(self.coverView.superview == nil)
    {
        [self.containerView addSubview:self.coverView];
    }
    
    [self.coverView bringSubviewToFront:self.partOneView];
    [self.coverView bringSubviewToFront:self.partTwoView];
    
    [self.coverView setHidden:NO];
    
    if(IsOpen == NO && IsOpenAnimated == YES)
    {
        [UIView beginAnimations:@"openFolder" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
//        if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderWillOpen:withFrame:)])
//        {
//            [_delegate OpenFolder:self folderWillOpen:self.contentController withFrame:self.contentView.frame];
//        }
    }
    
    CGRect tmpRect = self.partOneView.frame;
    if(_splitOrientation == SplitOrientationVertical)
    {
        tmpRect.origin.y = self.contentView.frame.origin.y - tmpRect.size.height;
    }
    else 
    {
        tmpRect.origin.x = self.contentView.frame.origin.x - tmpRect.size.width;
    }
    
    self.partOneView.frame = tmpRect;
    
    tmpRect = self.partTwoView.frame;
    if(_splitOrientation == SplitOrientationVertical)
    {
        tmpRect.origin.y = self.contentView.frame.origin.y+self.contentView.frame.size.height;
    }
    else 
    {
        tmpRect.origin.x = self.contentView.frame.origin.x+self.contentView.frame.size.width;
    }
    
    self.partTwoView.frame = tmpRect;
    
    if(IsOpen == NO && IsOpenAnimated == YES)
    {
        [UIView commitAnimations];
    }
    else 
    {
        [self MakeSubviewAlpha:self.containerView notWithView:self.coverView alpha:0.2];
        if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderDidOpen:withFrame:userInfo:)])
        {
            [_delegate OpenFolder:self folderDidOpen:self.contentController withFrame:self.contentView.frame userInfo:self.userInfo];
        }
    }
    
//    [self.partOneView setNeedsLayout];
//    [self.partTwoView setNeedsDisplay];
    
    IsOpen = YES;
}

- (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                         delegate:(id)delegate
{
    self.contentView = contentView;
    self.containerView = containerView;
    self.folderPosition = position;
    self.delegate = delegate;
    
    [self performSelector:@selector(dealOpenFolder) withObject:nil afterDelay:0.1];
//    [self ReFreshCurrentOpenFolder:nil];
}

- (void)openFolderWithController:(UIViewController *)contentController 
                        fromRect:(CGRect)fromRect 
                   containerView:(UIView *)containerView
                        delegate:(id)delegate 
                        userInfo:(NSDictionary*)userInfo 
                        animated:(BOOL)animated
{
    IsOpenAnimated = animated;
    _fromRect = fromRect;
    self.contentController = contentController;
    self.userInfo = userInfo;
    
    CGRect rc = containerView.bounds;
    CGPoint centerPt = CGPointMake(rc.origin.x + rc.size.width/2, rc.origin.y + rc.size.height/2);
    CGPoint position = CGPointZero;
    
    if(_splitOrientation == SplitOrientationVertical)
    {
        position.x = fromRect.origin.x+fromRect.size.width/2;
//        if(fromRect.origin.y+fromRect.size.height > centerPt.y+rc.size.height/4)
//        {
//            position.y = fromRect.origin.y;
//            _partOneArrowDirection = ArrowDirectionNone;
//            _partTwoArrowDirection = ArrowDirectiondDown;
//        }
//        else 
        {
            position.y = fromRect.origin.y+fromRect.size.height;
            _partOneArrowDirection = ArrowDirectionUp;
            _partTwoArrowDirection = ArrowDirectionNone;
        }
    }
    else 
    {
        position.y = fromRect.origin.y+fromRect.size.height/2;
        if(fromRect.origin.x+fromRect.size.width > centerPt.x+rc.size.width/4)
        {
            position.x = fromRect.origin.x;
            _partOneArrowDirection = ArrowDirectionNone;
            _partTwoArrowDirection = ArrowDirectionRight;
        }
        else 
        {
            position.x = fromRect.origin.x+fromRect.size.width;
            _partOneArrowDirection = ArrowDirectionLeft;
            _partTwoArrowDirection = ArrowDirectionNone;
        }
    }
    
    [self openFolderWithContentView:contentController.view position:position containerView:containerView delegate:delegate];
}

- (void)ReFreshCurrentOpenFolder:(CGRect)fromRect
{
    
    {
        _fromRect = fromRect;
    }
    
    CGRect rc = self.containerView.bounds;
    CGPoint centerPt = CGPointMake(rc.origin.x + rc.size.width/2, rc.origin.y + rc.size.height/2);
    CGPoint position = CGPointZero;
    
    if(_splitOrientation == SplitOrientationVertical)
    {
        position.x = _fromRect.origin.x+_fromRect.size.width/2;
        //        if(fromRect.origin.y+fromRect.size.height > centerPt.y+rc.size.height/4)
        //        {
        //            position.y = fromRect.origin.y;
        //            _partOneArrowDirection = ArrowDirectionNone;
        //            _partTwoArrowDirection = ArrowDirectiondDown;
        //        }
        //        else 
        {
            position.y = _fromRect.origin.y+_fromRect.size.height;
            _partOneArrowDirection = ArrowDirectionUp;
            _partTwoArrowDirection = ArrowDirectionNone;
        }
    }
    else 
    {
        position.y = _fromRect.origin.y+_fromRect.size.height/2;
        if(_fromRect.origin.x+_fromRect.size.width > centerPt.x+rc.size.width/4)
        {
            position.x = _fromRect.origin.x;
            _partOneArrowDirection = ArrowDirectionNone;
            _partTwoArrowDirection = ArrowDirectionRight;
        }
        else 
        {
            position.x = _fromRect.origin.x+_fromRect.size.width;
            _partOneArrowDirection = ArrowDirectionLeft;
            _partTwoArrowDirection = ArrowDirectionNone;
        }
    }

    self.folderPosition = position;
    
    [self.partOneView removeFromSuperview];
    self.partOneView = nil;
//    
    [self.partTwoView removeFromSuperview];
    self.partTwoView = nil;
    
//    [self dealOpenFolder];
    [self performSelector:@selector(dealOpenFolder) withObject:nil afterDelay:0.1];
}

- (BOOL)IsOpened
{
    return IsOpen;
}

- (void)CloseFolder:(BOOL)animated
{
    if(animated)
    {
        [self FolderWillClose];        
    }
    else 
    {
        if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderDidClose:userInfo:)])
        {
            [_delegate OpenFolder:self folderDidClose:self.contentController userInfo:self.userInfo];
        }
        
        [self CleanUp];
    }
}

#pragma mark - private functions

- (void)MakeSubviewAlpha:(UIView *)view notWithView:(UIView *)notWithView alpha:(CGFloat)alpha
{
//    self.partOneView.alpha = alpha;
//    self.partTwoView.alpha = alpha;
//    for(UIView *v in view.subviews)
//    {
//        if(v == notWithView || v == self.coverView)
//        {
//            continue;
//        }
//        v.alpha = alpha;
//    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if([finished boolValue])
    {
        if([animationID isEqualToString:@"openFolder"])
        {
            IsOpen = YES;
            [self MakeSubviewAlpha:self.containerView notWithView:nil alpha:0.2];
            
            if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderDidOpen:withFrame:userInfo:)])
            {
                [_delegate OpenFolder:self folderDidOpen:self.contentController withFrame:self.contentView.frame  userInfo:self.userInfo];
            }
        }
        else 
        {
            if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderDidClose:userInfo:)])
            {
                [_delegate OpenFolder:self folderDidClose:self.contentController userInfo:self.userInfo];
            }
            [self MakeSubviewAlpha:self.containerView notWithView:nil alpha:1.0];
            [self CleanUp];
            IsOpen = NO;
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag 
{
    
}

- (OpenFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen arrowDirection:(ArrowDirection)arrowDirection position:(CGPoint)position 
{
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    CGRect u1 = CGRectMake(origin.x, origin.y, width, height);
    
    OpenFolderSplitView *b1 = [[[OpenFolderSplitView alloc] initWithFrame:u1] autorelease];
    b1.arrowType = arrowDirection;
    b1.position = position;
    
    [self SetBackImage:b1 aRect:aRect andScreen:screen];
    
    return b1;
}

- (void)SetBackImage:(UIView*)theView aRect:(CGRect)aRect andScreen:(UIImage *)screen
{
    CGFloat scale = [UIScreen screenScale]; 
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    
    CGRect r1 = CGRectZero;
    if(_splitOrientation == SplitOrientationVertical)
    {
        r1 = CGRectMake(origin.x*scale, origin.y*scale, width*scale, height*scale);
    }
    else 
    {
        r1 = CGRectMake(origin.x*scale, origin.y*scale, width*scale, height*scale);
    }
    
    
    CGImageRef ref1 = CGImageCreateWithImageInRect([screen CGImage], r1);
    UIImage *img = [UIImage imageWithCGImage:ref1 scale: scale orientation: UIImageOrientationUp];
    CGImageRelease(ref1);
    
    [theView setBackgroundColor:[UIColor colorWithPatternImage:img]];
}

- (void)CleanUp
{
    if(self.partOneView.superview)
    {
        [self.partOneView removeFromSuperview];
    }
    self.partOneView = nil;
    
    if(self.partTwoView.superview)
    {
        [self.partTwoView removeFromSuperview];
    }
    self.partTwoView = nil;
    
    if(self.coverView.superview)
    {
        [self.coverView removeFromSuperview];
    }
    self.coverView = nil;
    
    self.contentController = nil;
    
    self.userInfo = nil;
    
    IsOpen = NO;
}

- (void)FolderWillClose
{
    IsOpen = NO;
    if(IsOpenAnimated)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderWillClose:userInfo:)])
        {
            [_delegate OpenFolder:self folderWillClose:self.contentController userInfo:self.userInfo];
        }
        
        [UIView beginAnimations:@"closeFolder" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

        CGRect tmpRect = self.partOneView.frame;
        if(_splitOrientation == SplitOrientationVertical)
        {
            tmpRect.origin.y = 0;
        }
        else 
        {
            tmpRect.origin.x = 0;
        }
        self.partOneView.frame = tmpRect;
        
        tmpRect = self.partTwoView.frame;
        if(_splitOrientation == SplitOrientationVertical)
        {
            tmpRect.origin.y = self.folderPosition.y;
        }
        else 
        {
            tmpRect.origin.x = self.folderPosition.x;
        }
        
        self.partTwoView.frame = tmpRect;
        
        [UIView commitAnimations];
    }
    else 
    {
        if(_delegate && [_delegate respondsToSelector:@selector(OpenFolder:folderDidClose:userInfo:)])
        {
            [_delegate OpenFolder:self folderDidClose:self.contentController userInfo:self.userInfo];
        }
        
        [self CleanUp];
    }
}

@end

#pragma mark - CoverView

@implementation CoverView

@synthesize partOneView;
@synthesize partTwoView;
@synthesize containderView;

@synthesize contentView;

@synthesize partOneRect;
@synthesize partTwoRect;

@synthesize position;

- (void)dealloc
{
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rc = self.contentView.frame;
    NSLog(@"%f,%f,%f,%f",rc.origin.x,rc.origin.y,rc.size.width,rc.size.height);
}

@end

#pragma mark - OpenFolderSplitView

@implementation OpenFolderSplitView

@synthesize arrowType, position;
@synthesize splitOrientation;
@synthesize fromRect;

- (void)drawRect:(CGRect)rect 
{    
   [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    if(self.arrowType > 0)
    {
        CGMutablePathRef contentPath = CGPathCreateMutable();
        
        if(self.arrowType == 1)
        {
            CGFloat w = self.fromRect.size.width/4;
            CGFloat h = self.fromRect.size.height/6;
            
            CGPathMoveToPoint(contentPath, NULL, 0, rect.size.height);
            CGPathAddLineToPoint(contentPath, NULL, self.position.x-w/2,rect.size.height);
            CGPathAddLineToPoint(contentPath, NULL, self.position.x,self.position.y-h);
            CGPathAddLineToPoint(contentPath, NULL, self.position.x+w/2,rect.size.height);
            CGPathAddLineToPoint(contentPath, NULL, rect.size.width,rect.size.height);
        }
        else if(self.arrowType == 2)
        {
            CGFloat w = self.fromRect.size.width/4;
            CGFloat h = self.fromRect.size.height/6;
            
            CGPathMoveToPoint(contentPath, NULL, 0, 0);
            CGPathAddLineToPoint(contentPath, NULL, self.position.x-w/2,0);
            CGPathAddLineToPoint(contentPath, NULL, self.position.x,h);
            CGPathAddLineToPoint(contentPath, NULL, self.position.x+w/2,0);
            CGPathAddLineToPoint(contentPath, NULL, rect.size.width,0);
        }
        else if(self.arrowType == 3)
        {
            CGFloat w = self.fromRect.size.width/6;
            CGFloat h = self.fromRect.size.height/4;
            
            CGPathMoveToPoint(contentPath, NULL, rect.size.width, 0);
            CGPathAddLineToPoint(contentPath, NULL, rect.size.width,self.position.y-h/2);
            CGPathAddLineToPoint(contentPath, NULL, rect.size.width-w,self.position.y);
            CGPathAddLineToPoint(contentPath, NULL, rect.size.width,self.position.y+h/25);
            CGPathAddLineToPoint(contentPath, NULL, rect.size.width,rect.size.height);
        }
        else if(self.arrowType == 4) 
        {
            CGFloat w = self.fromRect.size.width/6;
            CGFloat h = self.fromRect.size.height/4;

            CGPathMoveToPoint(contentPath, NULL, 0, 0);
            CGPathAddLineToPoint(contentPath, NULL, 0,self.position.y-h/25);
            CGPathAddLineToPoint(contentPath, NULL, w,self.position.y);
            CGPathAddLineToPoint(contentPath, NULL, 0,self.position.y+h/2);
            CGPathAddLineToPoint(contentPath, NULL, 0,rect.size.height);
        }

        CGContextAddPath(ctx, contentPath);
        CGContextClip(ctx);
        
        UIColor *col = ((CoverView *)self.superview).contentView.backgroundColor;
        
        CGContextBeginPath(ctx);
        CGContextSetFillColorWithColor(ctx,col.CGColor);
        CGContextAddPath(ctx, contentPath);
        CGContextFillPath(ctx);
        //    CGContextStrokePath(ctx);
        
        CGContextAddPath(ctx, contentPath);   
        CGContextSetRGBStrokeColor(ctx, 1.0, 0.98, 0.97, 0.78);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetLineCap(ctx,kCGLineCapRound);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextStrokePath(ctx);
        
        CGPathRelease(contentPath);
    }
    else 
    {
        CGContextSetRGBFillColor(ctx, 1.0, 0.98, 0.97, 0.78); //light color
        if (self.splitOrientation == SplitOrientationVertical)
        {
            CGContextFillRect(ctx, CGRectMake(0, rect.size.height-2, rect.size.width, 2));
            CGContextFillRect(ctx, CGRectMake(0, 0, rect.size.width, 2));
        }
        else 
        {
            CGContextFillRect(ctx, CGRectMake(0, 0, 2, rect.size.height));
            CGContextFillRect(ctx, CGRectMake(rect.size.width-2, 0, 2, rect.size.height));
        }
    }
    
    
    CGContextRestoreGState(ctx);
}

@end
//
//  OpenFolder.h
//  MyFolder
//
//  Created by yangjunying on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OpenFolderSplitView;
@class OpenFolder;
@class CoverView;

typedef enum
{
    SplitOrientationHorizontal = 0,
    SplitOrientationVertical
}SplitOrientation;

typedef enum
{
    ArrowDirectionNone = 0,
    ArrowDirectionUp,
    ArrowDirectiondDown,
    ArrowDirectionLeft,
    ArrowDirectionRight
}ArrowDirection;

@protocol OpenFolderDelegate <NSObject>

@optional

- (CGFloat)OpenFolder:(OpenFolder*)theFolder contentViewHeightOrWidth:(UIViewController*)contentController orientation:(SplitOrientation)splitOrientation userInfo:(id)userInfo;

- (void)OpenFolder:(OpenFolder*)theFolder folderWillOpen:(UIViewController*)contentController withFrame:(CGRect)frame userInfo:(id)userInfo;
- (void)OpenFolder:(OpenFolder*)theFolder folderDidOpen:(UIViewController*)contentController withFrame:(CGRect)frame userInfo:(id)userInfo;

- (void)OpenFolder:(OpenFolder*)theFolder folderWillClose:(UIViewController*)contentController userInfo:(id)userInfo;
- (void)OpenFolder:(OpenFolder*)theFolder folderDidClose:(UIViewController*)contentController userInfo:(id)userInfo;

@end

@interface OpenFolder : NSObject
{
    id<OpenFolderDelegate> _delegate;
    
    BOOL IsOpen;
    BOOL IsOpenAnimated;
    
    SplitOrientation _splitOrientation;
    ArrowDirection _partOneArrowDirection;
    ArrowDirection _partTwoArrowDirection;
    
    CGRect _fromRect;
    
    UIView *_contentView;
    
    CoverView *_coverView;
    
    UIView *_containerView;
    CGPoint _folderPosition;
    
    OpenFolderSplitView *_partOneView;
    OpenFolderSplitView *_partTwoView;
    UIViewController *_contentController;
    
    NSDictionary* _userInfo;
}

@property(nonatomic,assign) id<OpenFolderDelegate> delegate;
@property(nonatomic,assign) SplitOrientation splitOrientation;

@property(nonatomic,retain) UIViewController *contentController;
@property(nonatomic,assign) UIView *contentView;
@property(nonatomic,retain) CoverView *coverView;
@property(nonatomic,assign) UIView *containerView;
@property(nonatomic,assign) CGPoint folderPosition;

@property(nonatomic,retain) OpenFolderSplitView *partOneView;
@property(nonatomic,retain) OpenFolderSplitView *partTwoView;

@property(nonatomic,retain) NSDictionary* userInfo;

+ (OpenFolder *)ShareOpenFolder;


- (void)openFolderWithController:(UIViewController *)contentController 
                         fromRect:(CGRect)fromRect 
                    containerView:(UIView *)containerView
                        delegate:(id)delegate 
                        userInfo:(NSDictionary*)userInfo 
                        animated:(BOOL)animated;

- (void)ReFreshCurrentOpenFolder:(CGRect)fromRect;
- (BOOL)IsOpened;
- (void)CloseFolder:(BOOL)animated;

@end

@interface CoverView : UIView

@property(nonatomic,assign) UIView *partOneView;
@property(nonatomic,assign) UIView *partTwoView;
@property(nonatomic,assign) UIView *contentView;
@property(nonatomic,assign) UIView *containderView;

@property(nonatomic,assign) CGRect partOneRect;
@property(nonatomic,assign) CGRect partTwoRect;
@property(nonatomic)CGPoint position;

@end

@interface OpenFolderSplitView : UIControl
{
    
}

@property(nonatomic,assign)CGPoint position;
@property(nonatomic,assign)CGRect fromRect;
@property(nonatomic,assign)NSInteger arrowType;
@property(nonatomic,assign) SplitOrientation splitOrientation;

@end
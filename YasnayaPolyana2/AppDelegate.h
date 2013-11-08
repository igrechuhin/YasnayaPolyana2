//
//  AppDelegate.h
//  YasnayaPolyana2
//
//  Created by GoloVaZa on 01.05.13.
//  Copyright (c) 2013 pbsputnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JAPanoView.h"
#import "ModalImageView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIScrollViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate>
{
    UIWindow *window;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    MPMoviePlayerController *moviePlayerController;
    JAPanoView *panoView;
    ModalImageView *modalImageView;
    BOOL pageControlUsed;
    BOOL justLoaded;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, retain) JAPanoView *panoView;
@property (nonatomic, retain) ModalImageView *modalImageView;

- (void)changePageTo:(int)page animated:(BOOL)animated;
- (void)changeToCurrentPageAnimated:(BOOL)animated;
- (void)deviceOrientationDidChanged:(NSNotification*)note;
- (void)mediaPlayerDidExitFullScreen:(NSNotification*)note;

@end

//
//  AppDelegate.m
//  YasnayaPolyana2
//
//  Created by GoloVaZa on 01.05.13.
//  Copyright (c) 2013 pbsputnik. All rights reserved.
//

#import "AppDelegate.h"
#import "WebViewController.h"
#import "RootViewController.h"

static NSUInteger kNumberOfPages = 11;

@interface AppDelegate (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation AppDelegate

@synthesize window, scrollView, pageControl, viewControllers, moviePlayerController, panoView, modalImageView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerDidExitFullScreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    RootViewController *rootController = [RootViewController new];
    self.window.rootViewController = rootController;
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:screenBounds];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    [self.window.rootViewController.view addSubview:scrollView];
	
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    pageControl.hidden = YES;
    [self.window.rootViewController.view addSubview:pageControl];
	
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    pageControlUsed = NO;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)deviceOrientationDidChanged:(NSNotification*)note
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIDeviceOrientation deviceOrientation = [[note object] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    }
    //Никак не реагируем на ориентации типа "лежа"
    else if (!UIDeviceOrientationIsPortrait(deviceOrientation)) {
        return;
    }

    // устанавливаем флаг, чтобы игнорировать события скроллинга во время поворота экрана
    pageControlUsed = YES;

    scrollView.frame = screenBounds;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    
    if (panoView != nil) panoView.frame = screenBounds;
    if (modalImageView != nil) modalImageView.frame = screenBounds;
    
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        WebViewController *controller = [viewControllers objectAtIndex:i];
        if ((NSNull *)controller != [NSNull null])
        {
            [controller changeOrientation:[[note object] orientation]];
        }
    }

    //При повороте экрана промежуточные страницы окажутся смещенными относительно границ экрана,
    //чтобы это исправить - переходим на текущую страницу без анимации
    [self changeToCurrentPageAnimated:NO];
    pageControlUsed = NO;
}

- (void)mediaPlayerDidExitFullScreen:(NSNotification*)note
{
    if(self.moviePlayerController)
    {
        [self.moviePlayerController stop];
        [self.moviePlayerController.view removeFromSuperview];
    }
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
	
    WebViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[WebViewController alloc] initWithPageNumber:page];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
	
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void)unloadInvisiblePages
{
    for (int i = 0; i < kNumberOfPages; i++)
    {
        if (i < pageControl.currentPage - 1 || i > pageControl.currentPage + 1)
        {
            WebViewController *controller = [viewControllers objectAtIndex:i];
            if ((NSNull *)controller != [NSNull null])
            {
                if (nil != controller.view.superview)
                {
                    [controller.view removeFromSuperview];
                }
                [viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
                NSLog(@"Unload page: %d", i);
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (pageControlUsed) {
        return;
    }
    // Перелистываем страницу, если перетянуто более половины
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //pageControlUsed = NO;
    
    int page = pageControl.currentPage;
	
    // После перелистывания загружаем соседние страницы
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    [self unloadInvisiblePages];
}

// Данный метод вызывается, когда UIWebView собирается выполнить запрос.
// Нужные запросы перехватываются и выполняется нативный код.
// Таким образом, получается из кода реагировать на нажатия ссылок и т.д.
// Нужные запросы имеют следующий формат: "scheme"://"base""path"
// base сама по себе не используется и нужна, чтобы получить path,
// где удобно передавать параметры, в том числе множественные.
// Чтобы нужный запрос не попал в safari метод возвращяет NO.
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *command = url.scheme;
    NSString *operand = [url.path substringFromIndex:1];
    // open используется для вызова метода перемотки страниц
    // таким образом получется перелистывать страницы чисто нативными функциями без js или css
    if ([command isEqual:@"open"])
    {
        if (operand.length >= 1)
        {
            int page = [operand intValue];
            [self changePageTo:page animated:NO];
        }
    }
    // video используетя для запуска видео в стандартном плеере на полный экран
    else if ([command isEqual:@"video"])
    {
        if (operand.length >= 3)
        {
            NSBundle *mainBundle = [NSBundle mainBundle];
            NSString *videoURL = [mainBundle pathForResource:operand ofType:@"mp4" inDirectory:@"www/video"];
            NSURL *url = [NSURL fileURLWithPath:videoURL];
            self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
            if (self.moviePlayerController == nil) {
                return NO;
            }
            self.moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
            self.moviePlayerController.controlStyle = MPMovieControlStyleFullscreen;
            [self.moviePlayerController play];
            [self.window.rootViewController.view addSubview:self.moviePlayerController.view];
            CGRect rect = CGRectMake(512, 384, 0, 0);
            self.moviePlayerController.view.frame = rect;
            [self.moviePlayerController setFullscreen:YES animated:YES];
        }
    }
    // panorama используется для просмотра панорм
    else if ([command isEqual:@"panorama"])
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        // используем JAPanoView для просмотра панорам (свободная лицензия apache)
        panoView=[[JAPanoView alloc] initWithFrame:self.window.rootViewController.view.bounds];
        [panoView setFrontImage:
         [UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"img_0" ofType:@"png" inDirectory:operand]]
         rightImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"img_1" ofType:@"png" inDirectory:operand]]
         backImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"img_2" ofType:@"png" inDirectory:operand]]
         leftImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"img_3" ofType:@"png" inDirectory:operand]]
         topImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"img_4" ofType:@"png" inDirectory:operand]]
         bottomImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"img_5" ofType:@"png" inDirectory:operand]]];
        [self.window.rootViewController.view addSubview:panoView];
    }
    else if ([command isEqual:@"image"])
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        // В архиве получаем имя файла и расширение
        NSArray *parts = [operand componentsSeparatedByString:@"."];
        modalImageView = [[ModalImageView alloc] initWithFrame:self.window.rootViewController.view.bounds];
        modalImageView.image = [UIImage imageWithContentsOfFile:[mainBundle pathForResource:parts[0] ofType:parts[1] inDirectory:@"www/image"]];
        modalImageView.userInteractionEnabled = YES;
        modalImageView.contentMode = UIViewContentModeScaleAspectFit;
        modalImageView.backgroundColor = [UIColor blackColor];
        [self.window.rootViewController.view addSubview:modalImageView];
    }
    else return YES;
    return NO;
}

- (void)changePageTo:(int)page animated:(BOOL)animated
{
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    pageControl.currentPage = page;
    [self unloadInvisiblePages];

    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:animated];

    //pageControlUsed = NO;
}

- (void)changeToCurrentPageAnimated:(BOOL)animated
{
    int page = pageControl.currentPage;
    [self changePageTo:page animated:animated];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

@end

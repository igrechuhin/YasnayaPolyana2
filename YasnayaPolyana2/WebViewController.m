//
//  WebViewController.m
//  PageControlExample
//
//  Created by GoloVaZa on 07.04.13.
//
//

#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView;

- (id)initWithPageNumber:(int)page {
    if (self = [super init]) {
        pageNumber = page;
    }
    return self;
}

-(void) loadView
{
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    }
    webView = [[UIWebView alloc] initWithFrame:screenBounds];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    webView.delegate = appDelegate;
    self.view = webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *fileName = [NSString stringWithFormat:@"Page%d", pageNumber+1];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"html" inDirectory:@"www"]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];

    webView.scalesPageToFit = YES;
    webView.scrollView.delegate = self;
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    
    NSLog(@"view %d did load", pageNumber);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)changeOrientation:(UIDeviceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    }
    screenBounds.origin.x = screenBounds.size.width * pageNumber;
    self.view.frame = screenBounds;
}

// Это нужно, чтобы запретить зум страниц
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

@end
